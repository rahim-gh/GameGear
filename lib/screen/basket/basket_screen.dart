import 'package:flutter/material.dart';
import 'package:game_gear/shared/widget/appbar_widget.dart';

class BasketScreen extends StatefulWidget {
  const BasketScreen({
    super.key,
  });
  @override
  State<BasketScreen> createState() => _BasketScreenState();
}

class _BasketScreenState extends State<BasketScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: "Basket"),
    );
  }
}
