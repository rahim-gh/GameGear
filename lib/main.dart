import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:game_gear/firebase_options.dart';
import 'package:game_gear/shared/utils/logger_util.dart';
import 'package:logger/web.dart';
import 'screen/authentication/login_screen.dart';
import 'screen/authentication/signup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  applog('Initialize the firabse', level: Level.info);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  applog('App starting...', level: Level.info);
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
