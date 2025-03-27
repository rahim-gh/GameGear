import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../constant/app_theme.dart';
import '../utils/logger_util.dart';

class SnackbarWidget {
  /// Displays a standardized snackbar message.
  static void show({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    Color backgroundColor = AppTheme.accentColor,
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    try {
      final snackBar = SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: AppTheme.primaryColor),
        ),
        duration: duration,
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(
            bottom: 80, left: 16, right: 16), // Position above navbar
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(8),
        ),
        action: (actionLabel != null && onActionPressed != null)
            ? SnackBarAction(
                label: actionLabel,
                textColor: AppTheme.primaryColor,
                onPressed: onActionPressed,
              )
            : null,
      );

      // Clear any existing snackbars to maintain a clean interface.
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      logs('Snackbar displayed with message: $message', level: Level.info);
    } catch (e) {
      logs('Error showing snackbar: $e', level: Level.error);
      rethrow;
    }
  }
}
