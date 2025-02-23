import 'package:flutter/material.dart';
import 'screen/login_screen.dart';
import 'screen/signup_screen.dart'; // ✅ أضفنا استيراد ملف التسجيل

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
      routes: {
        'signup': (context) => const Signup(),
        'login': (context) => const LoginScreen(), // ✅ استخدم اسم صحيح
      },
    );
  }
}
