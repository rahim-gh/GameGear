import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:game_gear/shared/constant/app_asset.dart';
import 'package:game_gear/shared/model/user_model.dart';
import 'package:game_gear/shared/service/auth_service.dart';
import 'package:game_gear/shared/service/database_service.dart';
import 'package:game_gear/shared/widget/appbar_widget.dart';
import 'package:image_picker/image_picker.dart';

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
  final TextEditingController _passwordController = TextEditingController();

  // New field to hold the updated profile image in base64
  String? _profileImageBase64;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // Retrieve the current user data
    final user =
        await DatabaseService().getUser(AuthService().currentUser!.uid);
    if (user != null) {
      _fullNameController.text = user.fullName;
      _emailController.text = user.email;
      _passwordController.text = user.password;
    }
    setState(() {
      _user = user;
      _loading = false;
    });
  }

  // Function to pick an image from the gallery and convert it to base64
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
    if (_formKey.currentState!.validate()) {
      try {
        // Pass the new image base64 if available, otherwise keep the existing one
        await DatabaseService().updateUser(
          _user!.uid,
          _fullNameController.text,
          _emailController.text,
          _passwordController.text,
          _profileImageBase64 ?? _user!.imageBase64!,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating profile: $e")),
        );
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Helper to build the profile image widget
  Widget _buildProfileImage() {
    if (_profileImageBase64 != null) {
      // Use the newly picked image
      return CircleAvatar(
        radius: 50,
        backgroundImage: MemoryImage(base64Decode(_profileImageBase64!)),
      );
    } else if (_user?.imageBase64 != null) {
      // Use the existing image from Firestore
      return CircleAvatar(
        radius: 50,
        backgroundImage: MemoryImage(base64Decode(_user!.imageBase64!)),
      );
    } else {
      // Fallback to the default asset image
      return CircleAvatar(
        radius: 50,
        backgroundImage: AssetImage(AppAsset.logo),
      );
    }
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
                    // Profile Picture with onTap to change image
                    Center(
                      child: InkWell(
                        onTap: _pickImage,
                        child: _buildProfileImage(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Full Name Field
                    TextFormField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(
                        labelText: "Full Name",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => (value == null || value.isEmpty)
                          ? "Please enter your full name"
                          : null,
                    ),
                    const SizedBox(height: 16),
                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => (value == null || value.isEmpty)
                          ? "Please enter your email"
                          : null,
                    ),
                    const SizedBox(height: 16),
                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (value) => (value == null || value.isEmpty)
                          ? "Please enter your password"
                          : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveProfile,
                      child: const Text("Save Profile"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
