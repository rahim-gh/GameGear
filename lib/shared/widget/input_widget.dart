import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../constant/app_theme.dart';
import '../utils/logger_util.dart';

enum FieldType {
  email,
  password,
  userName,
  productName,
  normal,
  price,
  description,
  tags,
}

class InputFieldWidget extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final FieldType type;
  final bool obscure;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool requiredField;
  final Widget? suffixIcon;
  final Future<void> Function(dynamic value)? onChanged;

  const InputFieldWidget({
    super.key,
    required this.label,
    required this.controller,
    required this.type,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.requiredField = true,
    this.suffixIcon,
    this.onChanged,
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

    // Allow empty input if the field is optional.
    if (!widget.requiredField && input.isEmpty) {
      return null;
    }

    switch (widget.type) {
      case FieldType.email:
        final regex = RegExp(r'^[A-Za-z0-9._-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
        if (input.isEmpty) {
          return 'Email field cannot be empty';
        } else if (!regex.hasMatch(input)) {
          return 'Invalid email format';
        }
        break;
      case FieldType.password:
        final regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$');
        if (input.isEmpty) {
          return 'Password field cannot be empty';
        } else if (!regex.hasMatch(input)) {
          return 'Password must be at least 8 characters long and include uppercase, lowercase and digits';
        }
        break;
      case FieldType.userName:
        // User name: only letters and spaces, 2-50 characters.
        final regex = RegExp(r'^[A-Za-z\s]{2,50}$');
        if (input.isEmpty) {
          return 'User name cannot be empty';
        } else if (!regex.hasMatch(input)) {
          return 'User name must only contain letters and spaces (2-50 characters)';
        }
        break;
      case FieldType.productName:
        // Product name: allow letters, numbers, and common punctuation; must be at least 2 characters.
        if (input.isEmpty) {
          return 'Product name is required';
        } else if (input.length < 2) {
          return 'Product name must be at least 2 characters';
        }
        break;
      case FieldType.price:
        final regex = RegExp(r'^\d+\.?\d{0,2}$');
        if (input.isEmpty) {
          return 'Price field cannot be empty';
        } else if (!regex.hasMatch(input)) {
          return 'Enter a valid price';
        } else {
          try {
            final price = double.parse(input);
            if (price <= 0) return 'Price must be greater than 0';
          } catch (_) {
            return 'Enter a valid price';
          }
        }
        break;
      case FieldType.description:
        if (input.isEmpty) {
          return 'Description is required';
        } else if (input.length < 10) {
          return 'Description must be at least 10 characters';
        }
        break;
      case FieldType.tags:
        if (input.isEmpty) {
          return 'At least one tag is required';
        }
        final tags = input
            .split(',')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty);
        if (tags.isEmpty) {
          return 'At least one valid tag is required';
        }
        break;
      case FieldType.normal:
        // Fallback/default behavior.
        return null;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.type == FieldType.password ? _obscure : false,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      decoration: InputDecoration(
        labelText: widget.label,
        filled: true,
        fillColor: Colors.white,
        hintStyle: TextStyle(color: AppTheme.greyShadeColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        errorMaxLines: 2,
        suffixIcon: widget.type == FieldType.password
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
            : widget.suffixIcon,
      ),
      validator: _validator,
      onChanged: (value) {
        if (widget.onChanged != null) {
          widget.onChanged!(value).catchError((error) {
            logs('Error in onChanged callback: $error', level: Level.error);
          });
        }
      },
    );
  }
}
