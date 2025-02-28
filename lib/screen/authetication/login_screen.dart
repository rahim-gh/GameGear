import 'package:flutter/material.dart';
import 'package:game_gear/screen/home/home_screen.dart';
import 'package:game_gear/shared/service/database_service.dart';
import 'package:game_gear/shared/utils/logger_util.dart';
import 'package:game_gear/shared/widget/button_widget.dart';
import 'package:game_gear/shared/constant/app_asset.dart';
import 'package:game_gear/shared/constant/app_color.dart';
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

  @override
  void initState() {
    super.initState();
    emailFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
    applog('LoginScreen initialized', level: Level.info);
  }

  @override
  void dispose() {
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    emailController.dispose();
    passwordController.dispose();
    applog('LoginScreen disposed', level: Level.info);
    super.dispose();
  }

  void navigateToSignup() {
    applog('Initiating navigation to Signup Screen', level: Level.info);
    Navigator.of(context).pushReplacementNamed('signup_screen');
  }

  Future<void> handleLogin() async {
    try {
      if (!_formKey.currentState!.validate()) {
        applog('Form validation failed', level: Level.warning);
        return;
      }

      applog('Fetching users from database', level: Level.info);
      final users = await DatabaseService().getAllUsers();

      dynamic matchingUser;
      bool isPasswordValid = false;
      for (final user in users) {
        if (user.email == emailController.text.toLowerCase().trim()) {
          if (user.password == passwordController.text.trim()) {
            isPasswordValid = true;
          }

          matchingUser = user;
          break;
        }
      }

      if (!mounted) return;
      if (matchingUser == null) {
        SnackbarWidget.show(
          context: context,
          message: 'User not found.',
        );
        applog('User not found', level: Level.warning);
        return;
      }
      if (isPasswordValid == false) {
        SnackbarWidget.show(
          context: context,
          message: 'Incorrect password',
        );
        applog(
          'Incorrect password',
          level: Level.error,
        );
        return;
      }

      applog(
          'User found. Navigating to HomeScreen with user id: ${matchingUser.id}',
          level: Level.info);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) => HomeScreen(id: matchingUser.id)),
      );
    } catch (e) {
      SnackbarWidget.show(
        context: context,
        message: 'An error occurred: $e',
      );
      applog('Error during login: $e', level: Level.error);
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
                        style: TextStyle(
                          color: AppColor.greyShade,
                        ),
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
