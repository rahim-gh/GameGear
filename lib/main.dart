import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MaterialApp(
        title: 'GameGear',
        builder: _applyTextScaleFactor,
        home: _homeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  Widget _applyTextScaleFactor(BuildContext context, Widget? child) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
      child: child!,
    );
  }

  Widget _homeScreen() {
    return Scaffold(
      body: Center(
        child: Text('Hello, world!'),
      ),
    );
  }
}
