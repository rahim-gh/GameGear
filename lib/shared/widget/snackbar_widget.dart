import 'package:flutter/material.dart';
import 'package:game_gear/shared/constant/app_color.dart';
import 'package:game_gear/shared/utils/logger_util.dart';
import 'package:logger/logger.dart';

class SnackbarWidget {
  /// Displays a standardized snackbar message.
  ///
  /// The [context] is used to display the snackbar, and the [message] defines
  /// the content. Optional parameters allow for customization of duration,
  /// background color, and an action button.
  static void show({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    Color backgroundColor = AppColor.accent,
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    try {
      final snackBar = SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: backgroundColor,
        action: (actionLabel != null && onActionPressed != null)
            ? SnackBarAction(
                label: actionLabel,
                onPressed: onActionPressed,
              )
            : null,
      );

      // Clear existing snackbars to maintain a clean user interface.
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      logs('Snackbar displayed with message: $message', level: Level.info);
    } catch (e) {
      logs('Error showing snackbar: $e', level: Level.error);
      rethrow;
    }
  }
}
