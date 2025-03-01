import 'package:flutter/material.dart';

class SettingChoice extends StatelessWidget {
  final IconData leading;
  final String title;
  final VoidCallback onTap;
  const SettingChoice({
    super.key,
    required this.leading,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(leading),
      title: Text(title),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }
}
