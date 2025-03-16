import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
import 'package:flutter/material.dart';
import 'package:game_gear/shared/model/user_model.dart';
import 'package:game_gear/shared/service/auth_service.dart';
import 'package:game_gear/shared/service/database_service.dart';
import 'package:game_gear/shared/utils/logger_util.dart';
import 'package:game_gear/shared/widget/appbar_widget.dart';
import 'package:game_gear/shared/widget/button_widget.dart';
import 'package:game_gear/shared/widget/input_widget.dart';
import 'package:game_gear/shared/widget/snackbar_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';

class ProfileInfoScreen extends StatefulWidget {
  const ProfileInfoScreen({super.key});

  @override
  State<ProfileInfoScreen> createState() => _ProfileInfoScreenState();
}

class _ProfileInfoScreenState extends State<ProfileInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = true;
  User? _user;

  // Controllers for user info
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  // Holds the updated profile image as a base64 string.
  String? _profileImageBase64;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user =
        await DatabaseService().getUser(AuthService().currentUser!.uid);
    if (user != null) {
      _fullNameController.text = user.fullName;
      _emailController.text = AuthService().currentUser?.email ?? '';
    }
    setState(() {
      _user = user;
      _loading = false;
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imageFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      final File file = File(imageFile.path);
      final List<int> imageBytes = await file.readAsBytes();
      final String base64Image = base64Encode(imageBytes);
      setState(() {
        _profileImageBase64 = base64Image;
      });
    }
  }

  Future<void> _saveProfile() async {
    logs('Saving profile data...', level: Level.debug);

    if (_formKey.currentState!.validate()) {
      try {
        await AuthService().reauthenticateUser(_currentPasswordController.text);

        final currentUser = AuthService().currentUser;
        if (currentUser != null) {
          logs('Current auth email: ${currentUser.email}', level: Level.debug);

          if (currentUser.email != _emailController.text) {
            logs(
              'Updating auth email from ${currentUser.email} to ${_emailController.text}',
              level: Level.info,
            );
            await currentUser.verifyBeforeUpdateEmail(_emailController.text);
            logs('Verification email sent. Waiting for confirmation...',
                level: Level.info);

            const maxWaitTime = Duration(minutes: 5);
            const pollInterval = Duration(seconds: 10);
            final startTime = DateTime.now();
            bool emailUpdated = false;

            while (DateTime.now().difference(startTime) < maxWaitTime) {
              await currentUser.reload();
              final updatedUser = AuthService().currentUser;
              if (updatedUser != null &&
                  updatedUser.email == _emailController.text) {
                emailUpdated = true;
                break;
              }
              logs('Waiting for email confirmation...', level: Level.debug);
              await Future.delayed(pollInterval);
            }

            if (emailUpdated) {
              logs('Auth email confirmed and updated successfully',
                  level: Level.info);
              SnackbarWidget.show(
                context: context,
                message: "Email updated. Please sign in again.",
              );
              await AuthService().signOut(context);
              return; // End further processing as user is signed out.
            } else {
              logs(
                'Email verification timed out. Please verify your new email and try again.',
                level: Level.warning,
              );
              if (!mounted) return;
              SnackbarWidget.show(
                context: context,
                message:
                    "Email verification timed out. Please verify your new email and try again.",
              );
              return;
            }
          }

          if (_newPasswordController.text.isNotEmpty) {
            logs('Updating auth password...', level: Level.info);
            await currentUser.updatePassword(_newPasswordController.text);
            logs('Auth password updated successfully', level: Level.info);
          }
        } else {
          logs('No authenticated user found', level: Level.error);
        }

        final imageToSave = _profileImageBase64 ?? _user?.imageBase64;

        logs('Updating Firestore for user info...', level: Level.debug);
        final uid = currentUser!.uid;
        await DatabaseService().updateUser(
          uid,
          _fullNameController.text,
          imageToSave,
        );
        logs('Firestore updated successfully for user info', level: Level.info);

        if (!mounted) return;
        SnackbarWidget.show(
          context: context,
          message: "Profile updated successfully",
        );
      } on FirebaseAuthException catch (e, stacktrace) {
        // If the token is expired, force sign-out.
        if (e.code == 'user-token-expired') {
          logs('User token expired. Forcing sign out.', level: Level.error);
          await AuthService().signOut(context);
          if (!mounted) return;
          SnackbarWidget.show(
            context: context,
            message: "Session expired. Please sign in again.",
          );
        } else {
          logs('Error updating profile: $e',
              level: Level.error, error: e, stackTrace: stacktrace);
          if (!mounted) return;
          SnackbarWidget.show(
            context: context,
            message: "Error updating profile: $e",
          );
        }
      } catch (e, stacktrace) {
        logs('Error updating profile: $e',
            level: Level.error, error: e, stackTrace: stacktrace);
        if (!mounted) return;
        SnackbarWidget.show(
          context: context,
          message: "Error updating profile: $e",
        );
      }
    } else {
      logs('Profile form validation failed', level: Level.warning);
    }
  }

  Widget _buildProfileImage() {
    if (_profileImageBase64 != null && _profileImageBase64!.isNotEmpty) {
      return CircleAvatar(
        radius: 50,
        backgroundImage: MemoryImage(base64Decode(_profileImageBase64!)),
      );
    } else if (_user?.imageBase64 != null && _user!.imageBase64!.isNotEmpty) {
      return CircleAvatar(
        radius: 50,
        backgroundImage: MemoryImage(base64Decode(_user!.imageBase64!)),
      );
    } else {
      final fallbackUrl =
          'https://ui-avatars.com/api/?name=${Uri.encodeComponent(_user?.fullName ?? "Unknown")}&format=png';
      return CircleAvatar(
        radius: 50,
        backgroundImage: NetworkImage(fallbackUrl),
      );
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: "Profile Info"),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: InkWell(
                        onTap: _pickImage,
                        child: _buildProfileImage(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    InputFieldWidget(
                      label: 'Full Name',
                      controller: _fullNameController,
                      type: 'name',
                    ),
                    const SizedBox(height: 16),
                    InputFieldWidget(
                      label: 'Email',
                      controller: _emailController,
                      type: 'email',
                    ),
                    const SizedBox(height: 16),
                    InputFieldWidget(
                      label: 'Current Password',
                      controller: _currentPasswordController,
                      type: 'password',
                    ),
                    const SizedBox(height: 16),
                    InputFieldWidget(
                      label: 'New Password (optional)',
                      controller: _newPasswordController,
                      type: 'password',
                      requiredField: false,
                    ),
                    const SizedBox(height: 20),
                    ButtonWidget(
                      label: 'Save Profile',
                      onPressed: _saveProfile,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
