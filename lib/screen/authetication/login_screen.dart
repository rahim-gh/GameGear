import 'package:flutter/material.dart';
import 'package:game_gear/screen/home/home_screen.dart';
import 'package:game_gear/shared/service/database_service.dart';
import 'package:game_gear/shared/utils/logger_util.dart';
import 'package:game_gear/shared/widget/input_widget.dart';
import 'package:game_gear/shared/widget/button_widget.dart';
import 'package:game_gear/shared/constant/app_asset.dart';
import 'package:game_gear/shared/constant/app_color.dart';
import 'package:game_gear/shared/widget/snackbar_widget.dart';
import 'package:logger/logger.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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

  bool _validateAllInputs() {
    final bool isEmailValid = _validateInput(emailController.text, 'email');
    final bool isPasswordValid =
        _validateInput(passwordController.text, 'password');

    if (!isEmailValid) {
      SnackbarWidget.show(
        context: context,
        message: 'Please enter a valid email address.',
      );
    }
    if (!isPasswordValid) {
      SnackbarWidget.show(
        context: context,
        message: 'Password must be at least 6 characters long.',
      );
    }

    applog(
      'Inputs validated: Email - $isEmailValid, Password - $isPasswordValid',
      level: Level.info,
    );
    return isEmailValid && isPasswordValid;
  }

  bool _validateInput(String value, String type) {
    if (type == 'email') {
      return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value);
    } else if (type == 'password') {
      return value.length >= 8;
    }
    return false;
  }

  void handleLogin() async {
    try {
      if (!_validateAllInputs()) {
        applog(
          'Form validation failed',
          level: Level.warning,
        );
        return;
      }

      applog(
        'Fetching users from database',
        level: Level.info,
      );
      final users = await DatabaseService().getAllUsers();

      // Utilize a loop to safely identify the matching user,
      // mitigating runtime exceptions from firstWhere.
      dynamic matchingUser;
      for (final user in users) {
        if (user.email == emailController.text) {
          matchingUser = user;
          break;
        }
      }

      if (matchingUser == null) {
        if (mounted) {
          SnackbarWidget.show(
            context: context,
            message: 'User not found.',
          );
        }
        applog(
          'User not found',
          level: Level.warning,
        );
        return;
      }

      applog(
        'User found. Navigating to HomeScreen with user id: ${matchingUser.id}',
        level: Level.info,
      );
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomeScreen(id: matchingUser.id),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        SnackbarWidget.show(
          context: context,
          message: 'An error occurred: $e',
        );
      }
      applog(
        'Error during login: $e',
        level: Level.error,
      );
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
                InputWidget(
                  controller: emailController,
                  label: 'Email',
                  inputAction: TextInputAction.next,
                  type: 'email',
                  onEditingComplete: () =>
                      FocusScope.of(context).requestFocus(emailFocusNode),
                ),
                const SizedBox(height: 20),
                InputWidget(
                  controller: passwordController,
                  label: 'Password',
                  keyboardType: TextInputType.visiblePassword,
                  obscure: true,
                  inputAction: TextInputAction.done,
                  type: 'password',
                  onEditingComplete: () =>
                      FocusScope.of(context).requestFocus(passwordFocusNode),
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
                    const Text("Don't have an account? "),
                    TextButton(
                      onPressed: navigateToSignup,
                      child: const Text(
                        "Sign up",
                        style: TextStyle(color: Colors.green),
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
    );
  }
}
