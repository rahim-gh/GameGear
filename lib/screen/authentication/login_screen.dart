import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:game_gear/screen/main/main_screen.dart';
import 'package:game_gear/shared/constant/app_asset.dart';
import 'package:game_gear/shared/constant/app_color.dart';
import 'package:game_gear/shared/service/auth_service.dart';
import 'package:game_gear/shared/utils/logger_util.dart';
import 'package:game_gear/shared/widget/button_widget.dart';
import 'package:game_gear/shared/widget/input_widget.dart';
import 'package:game_gear/shared/widget/snackbar_widget.dart';
import 'package:logger/logger.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  late final FocusNode emailFocusNode;
  late final FocusNode passwordFocusNode;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    emailFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
    logs('LoginScreen initialized', level: Level.info);
  }

  @override
  void dispose() {
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    emailController.dispose();
    passwordController.dispose();
    logs('LoginScreen disposed', level: Level.info);
    super.dispose();
  }

  void navigateToSignup() {
    logs('Navigating to Signup Screen', level: Level.info);
    Navigator.of(context).pushReplacementNamed('signup_screen');
  }

  Future<void> handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      logs('Form validation failed', level: Level.warning);
      return;
    }

    try {
      final String email = emailController.text.toLowerCase().trim();
      final String password = passwordController.text.trim();

      logs('Attempting to sign in user via Firebase Auth', level: Level.info);
      final UserCredential credential = await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      if (!mounted) return;
      logs(
          'Login successful. Navigating to HomeScreen with uid: ${credential.user?.uid}',
          level: Level.info);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          // builder: (context) => HomeScreen(uid: credential.user!.uid)),
          builder: (context) => MainScreen(uid: credential.user!.uid),
        ),
      );
    } on FirebaseAuthException catch (e) {
      logs('Login failed: ${e.message}', level: Level.error);
      SnackbarWidget.show(
          context: context, message: 'Login failed: ${e.message}');
    } catch (e) {
      logs('Unexpected error during login: $e', level: Level.error);
      SnackbarWidget.show(context: context, message: 'Login failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primary,
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
                    "Login",
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
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
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 60),
                  ButtonWidget(
                    label: 'Login',
                    onPressed: handleLogin,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(color: AppColor.greyShade),
                      ),
                      TextButton(
                        onPressed: navigateToSignup,
                        child: const Text(
                          "Sign up",
                          style: TextStyle(
                            color: AppColor.accent,
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
