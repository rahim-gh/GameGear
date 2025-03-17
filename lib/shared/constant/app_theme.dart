import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFFFFFFF);
  static const Color secondaryColor = Color(0xFFF7F7F7);
  static const Color accentColor = Color(0xFF000000);

  // example: Text hint
  static const Color greyShadeColor = Colors.grey;
  static const TextStyle titleStyle = TextStyle(
    overflow: TextOverflow.ellipsis,
    color: AppTheme.accentColor,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );
  static BoxDecoration cardDecoration = BoxDecoration(
    border: Border.all(color: Colors.black),
    borderRadius: BorderRadius.circular(20),
    color: AppTheme.primaryColor,
  );
  static ButtonStyle buttonStyle = ButtonStyle(
    backgroundColor: WidgetStateProperty.all(AppTheme.accentColor),
    foregroundColor: WidgetStateProperty.all(AppTheme.primaryColor),
    textStyle: WidgetStateProperty.all(
      TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
