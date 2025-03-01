import 'package:flutter/material.dart';

class SettingChoiceWidget extends StatelessWidget {
  final IconData leading;
  final String title;
  final VoidCallback onTap;
  const SettingChoiceWidget({
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
