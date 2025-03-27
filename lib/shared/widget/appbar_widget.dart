// appbar_widget.dart
import 'package:flutter/material.dart';

import '../constant/app_theme.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize = const Size.fromHeight(kToolbarHeight);
  final String title;
  // final List<Widget>? actions;

  const AppBarWidget({
    super.key,
    required this.title,
    // this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.primaryColor,
      elevation: 0,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      // actions: actions,
    );
  }
}
