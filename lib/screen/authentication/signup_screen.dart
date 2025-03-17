import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../../shared/constant/app_asset.dart';
import '../../shared/constant/app_theme.dart';
import '../../shared/service/auth_service.dart';
import '../../shared/service/database_service.dart';
import '../../shared/utils/logger_util.dart';
import '../../shared/widget/button_widget.dart';
import '../../shared/widget/input_widget.dart';
import '../../shared/widget/snackbar_widget.dart';
import '../main/main_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  late final FocusNode fullNameFocusNode;
  late final FocusNode emailFocusNode;
  late final FocusNode passwordFocusNode;
  late final FocusNode confirmPasswordFocusNode;

  // State variable to capture whether the user is a shop owner.
  bool _isShopOwner = false;

  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    fullNameFocusNode = FocusNode();
    emailFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
    confirmPasswordFocusNode = FocusNode();
    logs('SignupScreen initialized', level: Level.info);
  }

  @override
  void dispose() {
    fullNameFocusNode.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    logs('SignupScreen disposed', level: Level.info);
    super.dispose();
  }

  void navigateToLogin() {
    logs('Navigating to Login Screen', level: Level.info);
    Navigator.of(context).pushReplacementNamed('login_screen');
  }

  Future<void> handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      logs('Form validation failed', level: Level.warning);
      return;
    }
    if (passwordController.text.trim() !=
        confirmPasswordController.text.trim()) {
      logs('Password confirmation failed', level: Level.warning);
      SnackbarWidget.show(context: context, message: 'Passwords do not match.');
      return;
    }

    try {
      final String email = emailController.text.toLowerCase().trim();
      final String password = passwordController.text.trim();
      final String fullname = fullNameController.text.trim();

      logs('Attempting to sign up user via Firebase Auth', level: Level.info);
      final UserCredential credential = await _authService.signUpWithEmail(
        email: email,
        password: password,
      );

      // Ensure the newly registered user is authenticated.
      final String uid = credential.user!.uid;

      // Create the Firestore user document.
      // Do not store email, password, or uid in Firestore.
      await _databaseService.addUser(
        uid,
        fullname,
        isShopOwner: _isShopOwner,
      );

      if (!mounted) return;
      logs('User signed up successfully with uid: $uid', level: Level.info);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MainScreen(uid: uid)),
      );
    } on FirebaseAuthException catch (e) {
      logs('Signup failed: ${e.message}', level: Level.error);
      SnackbarWidget.show(
          context: context, message: 'Signup failed: ${e.message}');
    } catch (e) {
      logs('Unexpected error during signup: $e', level: Level.error);
      SnackbarWidget.show(context: context, message: 'Signup failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  Image.asset(AppAsset.logo, height: 150),
                  const SizedBox(height: 10),
                  const Text(
                    "Sign Up",
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  InputFieldWidget(
                    controller: fullNameController,
                    label: 'Fullname',
                    type: 'name',
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.name,
                  ),
                  const SizedBox(height: 20),
                  InputFieldWidget(
                    controller: emailController,
                    label: 'Email',
                    type: 'email',
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  InputFieldWidget(
                    controller: passwordController,
                    label: 'Password',
                    type: 'password',
                    obscure: true,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 20),
                  InputFieldWidget(
                    controller: confirmPasswordController,
                    label: 'Confirm Password',
                    type: 'password',
                    obscure: true,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 20),
                  // Checkbox for shop owner selection
                  CheckboxListTile(
                    title: const Text("I am a shop owner"),
                    value: _isShopOwner,
                    activeColor: AppTheme.accentColor,
                    checkColor: AppTheme.primaryColor,
                    onChanged: (bool? value) {
                      setState(() {
                        _isShopOwner = value ?? false;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  ButtonWidget(
                    label: 'Sign Up',
                    onPressed: handleSignUp,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account? ",
                        style: TextStyle(color: AppTheme.greyShadeColor),
                      ),
                      TextButton(
                        onPressed: navigateToLogin,
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            color: AppTheme.accentColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
