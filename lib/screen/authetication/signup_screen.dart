import 'package:flutter/material.dart';
import 'package:game_gear/screen/home/home_screen.dart';
import 'package:game_gear/shared/constant/app_asset.dart';
import 'package:game_gear/shared/constant/app_color.dart';
import 'package:game_gear/shared/service/database_service.dart';
import 'package:game_gear/shared/utils/logger_util.dart';
import 'package:game_gear/shared/widget/button_widget.dart';
import 'package:game_gear/shared/widget/input_widget.dart';
import 'package:game_gear/shared/widget/snackbar_widget.dart';
import 'package:logger/logger.dart';

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

  Future<void> handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      applog('Form validation failed', level: Level.warning);
      return;
    }
    try {
      applog('Attempting to add new user to the database', level: Level.info);
      final id = await DatabaseService().addUser(
        fullNameController.text.trim(),
        emailController.text.trim(),
        passwordController.text,
      );
      if (!mounted) return;
      if (id == null) {
        applog('Signup failed: User already exists', level: Level.warning);
        SnackbarWidget.show(
          context: context,
          message: 'User already exists, try signing in instead.',
        );
        return;
      }

      applog('User created successfully with id: $id', level: Level.info);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomeScreen(id: id)),
      );
    } catch (e) {
      applog('Error during signup: $e', level: Level.error);
      SnackbarWidget.show(
        context: context,
        message: 'An error occurred during signup: $e',
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
                  CustomTextField(
                    controller: fullNameController,
                    label: 'Fullname',
                    type: 'name',
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: emailController,
                    label: 'Email',
                    type: 'email',
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: passwordController,
                    label: 'Password',
                    type: 'password',
                    obscure: true,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.done,
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
                        style: TextStyle(
                          color: AppColor.greyShade,
                        ),
                      ),
                      TextButton(
                        onPressed: navigateToLogin,
                        child: const Text(
                          "Login",
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
