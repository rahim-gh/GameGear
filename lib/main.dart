import 'package:flutter/material.dart';
import 'screen/authetication/login_screen.dart';
import 'screen/authetication/signup_screen.dart'; // ✅ أضفنا استيراد ملف التسجيل

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MaterialApp(
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(1.0),
            ),
            child: child!,
          );
        },
        debugShowCheckedModeBanner: false,
        home: const LoginScreen(),
        routes: {
          'signup_screen': (context) => const SignupScreen(),
          'login_screen': (context) => const LoginScreen(),
        },
      ),
    );
  }
}
