import 'package:flutter/material.dart';
import 'package:game_gear/shared/constant/app_color.dart';
import 'package:game_gear/shared/utils/logger_util.dart';
import 'package:game_gear/shared/widget/snackbar_widget.dart';
import 'package:logger/web.dart';

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
        SnackbarWidget.show(
          context: context,
          message: 'Email field cannot be empty',
        );
      } else if (!regex.hasMatch(input)) {
        SnackbarWidget.show(
          context: context,
          message: 'Invalid email format',
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
        SnackbarWidget.show(
          context: context,
          message: 'Password field cannot be empty',
        );
      } else if (!regex.hasMatch(input)) {
        SnackbarWidget.show(
          context: context,
          message:
              'Password must be at least 8 characters long and include uppercase, lowercase, digits, and special characters',
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
        SnackbarWidget.show(
          context: context,
          message: 'Name field cannot be empty',
        );
      } else if (!regex.hasMatch(input)) {
        SnackbarWidget.show(
          context: context,
          message:
              'Name must only contain letters and spaces, and be 2-50 characters long',
        );
      } else {
        isValid = true;
      }
    }
    // Unsupported Type
    else {
      applog('Unsupported field type', level: Level.error);
      SnackbarWidget.show(
        context: context,
        message: 'Unsupported field type',
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
      hintStyle: TextStyle(
        color: AppColor.greyShade,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
    );
  }
}
