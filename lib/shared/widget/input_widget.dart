import 'package:flutter/material.dart';

class InputWidget extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscure;
  final TextInputAction inputAction;
  final void Function() onEditingComplete;

  /// 'email', 'password', 'name'.
  final String type;

  const InputWidget({
    super.key,
    required this.label,
    required this.controller,
    required this.inputAction,
    required this.type,
    required this.onEditingComplete,
    this.keyboardType = TextInputType.emailAddress,
    this.obscure = false,
  });

  @override
  State<InputWidget> createState() => _InputWidgetState();
}

class _InputWidgetState extends State<InputWidget> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      textInputAction: widget.inputAction,
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscure,
      decoration: _decoration(),
      onEditingComplete: () {
        validateInput(widget.type);
      },
    );
  }

  bool validateInput(String type) {
    final String input = widget.controller.text.trim();
    bool isValid = false;

    // Email Validation
    if (type.toLowerCase() == 'email') {
      final String regexPattern =
          r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';
      final RegExp regex = RegExp(regexPattern);
      if (input.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email field cannot be empty')),
        );
      } else if (!regex.hasMatch(input)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid email format')),
        );
      } else {
        isValid = true;
      }
    }
    // Password Validation
    else if (type.toLowerCase() == 'password') {
      final String regexPattern =
          r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$';
      final RegExp regex = RegExp(regexPattern);
      if (input.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password field cannot be empty')),
        );
      } else if (!regex.hasMatch(input)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Password must be at least 8 characters long and include uppercase, lowercase, digits, and special characters')),
        );
      } else {
        isValid = true;
      }
    }
    // Name Validation
    else if (type.toLowerCase() == 'name') {
      final String regexPattern = r'^[A-Za-z\s]{2,50}$';
      final RegExp regex = RegExp(regexPattern);
      if (input.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Name field cannot be empty')),
        );
      } else if (!regex.hasMatch(input)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Name must only contain letters and spaces, and be 2-50 characters long')),
        );
      } else {
        isValid = true;
      }
    }
    // Unsupported Type
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unsupported field type')),
      );
    }

    return isValid;
  }

  // Decoration for TextField
  InputDecoration _decoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: widget.label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
    );
  }
}
