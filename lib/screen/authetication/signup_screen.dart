import 'package:flutter/material.dart';
import 'package:game_gear/screen/home/home_screen.dart';
import 'package:game_gear/shared/constant/app_asset.dart';
import 'package:game_gear/shared/constant/app_color.dart';
import 'package:game_gear/shared/service/database_service.dart';
import 'package:game_gear/shared/widget/button_widget.dart';
import 'package:game_gear/shared/widget/input_widget.dart';
import 'package:game_gear/shared/utils/logger_util.dart';
import 'package:game_gear/shared/widget/snackbar_widget.dart';
import 'package:logger/logger.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  late final FocusNode fullNameFocusNode;
  late final FocusNode emailFocusNode;
  late final FocusNode passwordFocusNode;

  @override
  void initState() {
    super.initState();
    fullNameFocusNode = FocusNode();
    emailFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
    applog('SignupScreen initialized', level: Level.info);
  }

  @override
  void dispose() {
    fullNameFocusNode.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    applog('SignupScreen disposed', level: Level.info);
    super.dispose();
  }

  void navigateToLogin() {
    applog('Navigating to Login Screen', level: Level.info);
    Navigator.of(context).pushReplacementNamed('login_screen');
  }

  bool _validateAllInputs() {
    final bool isNameValid = _validateInput(fullNameController.text, 'name');
    final bool isEmailValid = _validateInput(emailController.text, 'email');
    final bool isPasswordValid =
        _validateInput(passwordController.text, 'password');

    if (!isNameValid || !isEmailValid || !isPasswordValid) {
      SnackbarWidget.show(
        context: context,
        message: 'Please fix the errors in the form.',
      );
    }

    applog(
      'Input validation: Name - $isNameValid, Email - $isEmailValid, Password - $isPasswordValid',
      level: Level.info,
    );
    return isNameValid && isEmailValid && isPasswordValid;
  }

  bool _validateInput(String value, String type) {
    switch (type) {
      case 'name':
        return value.trim().isNotEmpty;
      case 'email':
        return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value);
      case 'password':
        return value.length >= 6;
      default:
        return false;
    }
  }

  Future<void> handleSignUp() async {
    if (!_validateAllInputs()) return;

    try {
      applog('Attempting to add new user to the database', level: Level.info);
      final id = await DatabaseService().addUser(
        fullNameController.text.trim(),
        emailController.text.trim(),
        passwordController.text,
      );

      if (id == null) {
        applog(
          'Signup failed: User creation returned a null id',
          level: Level.warning,
        );
        if (mounted) {
          SnackbarWidget.show(
            context: context,
            message: 'User already exist, try signing in instead.',
          );
        }
        return;
      }

      applog('User created successfully with id: $id', level: Level.info);
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen(id: id)),
        );
      }
    } catch (e) {
      applog('Error during signup: $e', level: Level.error);
      if (mounted) {
        SnackbarWidget.show(
          context: context,
          message: 'An error occurred during signup: $e',
        );
      }
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
                  "Sign Up",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                InputWidget(
                  controller: fullNameController,
                  label: 'Fullname',
                  keyboardType: TextInputType.name,
                  inputAction: TextInputAction.next,
                  type: 'name',
                  onEditingComplete: () =>
                      FocusScope.of(context).requestFocus(fullNameFocusNode),
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
                  obscure: true,
                  keyboardType: TextInputType.visiblePassword,
                  inputAction: TextInputAction.done,
                  type: 'password',
                  onEditingComplete: () =>
                      FocusScope.of(context).requestFocus(passwordFocusNode),
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
                    const Text("Already have an account? "),
                    TextButton(
                      onPressed: navigateToLogin,
                      child: const Text(
                        "Login",
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
