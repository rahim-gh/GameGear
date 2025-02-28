import 'package:flutter/material.dart';
import 'package:game_gear/shared/constant/app_color.dart';
import 'package:game_gear/shared/utils/logger_util.dart';
import 'package:logger/logger.dart';

class InputFieldWidget extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String type; // 'email', 'password', 'name', 'normal'
  final bool obscure;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;

  const InputFieldWidget({
    super.key,
    required this.label,
    required this.controller,
    required this.type,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
  });

  @override
  State<InputFieldWidget> createState() => _InputFieldWidgetState();
}

class _InputFieldWidgetState extends State<InputFieldWidget> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscure;
  }

  String? _validator(String? value) {
    final input = value?.trim() ?? '';

    if (widget.type.toLowerCase() == 'email') {
      final regex = RegExp(r'^[A-Za-z0-9._-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
      if (input.isEmpty) {
        return 'Email field cannot be empty';
      } else if (!regex.hasMatch(input)) {
        return 'Invalid email format';
      }
    } else if (widget.type.toLowerCase() == 'password') {
      final regex =
          // RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&]).{8,}$');
          RegExp(
              r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$'); // simplified version
      if (input.isEmpty) {
        return 'Password field cannot be empty';
      } else if (!regex.hasMatch(input)) {
        return 'Password must be at least 8 characters long and include uppercase, lowercase and digits';
      }
    } else if (widget.type.toLowerCase() == 'name') {
      final regex = RegExp(r'^[A-Za-z\s]{2,50}$');
      if (input.isEmpty) {
        return 'Name field cannot be empty';
      } else if (!regex.hasMatch(input)) {
        return 'Name must only contain letters and spaces (2-50 characters)';
      }
    } else if (widget.type.toLowerCase() == 'normal') {
      // No validation rules for a normal text field.
      return null;
    } else {
      applog('Unsupported field type: ${widget.type}', level: Level.error);
      return 'Unsupported field type';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.type.toLowerCase() == 'password' ? _obscure : false,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      decoration: InputDecoration(
        labelText: widget.label,
        filled: true,
        fillColor: Colors.white,
        hintStyle: TextStyle(color: AppColor.greyShade),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        errorMaxLines: 2,
        suffixIcon: widget.type.toLowerCase() == 'password'
            ? IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () {
                  setState(() {
                    _obscure = !_obscure;
                  });
                },
              )
            : null,
      ),
      validator: _validator,
    );
  }
}
