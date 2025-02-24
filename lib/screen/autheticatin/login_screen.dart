import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_gear/screen/home/home_screen.dart';
import 'package:game_gear/shared/widget/input_widget.dart';
import 'package:game_gear/shared/widget/button_widget.dart';
import 'package:game_gear/shared/constant/app_asset.dart';
import 'package:game_gear/shared/constant/app_color.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  late FocusNode emailFocusNode;
  late FocusNode passwordFocusNode;

  @override
  void initState() {
    super.initState();
    emailFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void navigateToSignup() {
    Navigator.of(context).pushReplacementNamed('signup_screen');
  }

  bool _validateAllInputs() {
    bool isEmailValid = _validateInput(emailController.text, 'email');
    bool isPasswordValid = _validateInput(passwordController.text, 'password');

    if (!isEmailValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid email address.')),
      );
    }

    if (!isPasswordValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password must be at least 6 characters long.')),
      );
    }

    return isEmailValid && isPasswordValid;
  }

  bool _validateInput(String value, String type) {
    if (type == 'email') {
      return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value);
    } else if (type == 'password') {
      return value.length >= 6;
    }
    return false;
  }

  void handleLogin() {
    if (_validateAllInputs()) {
      // Simulate successful login and navigate to HomeScreen
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
                // Submit button
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
