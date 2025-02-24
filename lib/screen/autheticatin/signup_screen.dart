import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_gear/screen/home/home_screen.dart';
import 'package:game_gear/shared/constant/app_asset.dart';
import 'package:game_gear/shared/constant/app_color.dart';
import 'package:game_gear/shared/widget/button_widget.dart';
import 'package:game_gear/shared/widget/input_widget.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  late FocusNode fullNameFocusNode;
  late FocusNode emailFocusNode;
  late FocusNode passwordFocusNode;

  @override
  void initState() {
    super.initState();
    fullNameFocusNode = FocusNode();
    emailFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    fullNameFocusNode.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void navigateToLogin() {
    Navigator.of(context).pushReplacementNamed('login_screen');
  }

  bool _validateAllInputs() {
    bool isFullNameValid = _validateInput(fullNameController.text, 'name');
    bool isEmailValid = _validateInput(emailController.text, 'email');
    bool isPasswordValid = _validateInput(passwordController.text, 'password');

    return isFullNameValid && isEmailValid && isPasswordValid;
  }

  bool _validateInput(String value, String type) {
    if (type == 'name') {
      return value.isNotEmpty;
    } else if (type == 'email') {
      return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value);
    } else if (type == 'password') {
      return value.length >= 6;
    }
    return false;
  }

  void handleSignUp() {
    if (_validateAllInputs()) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fix the errors in the form.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.secondary,
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
                  label: 'Password',
                  controller: passwordController,
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
