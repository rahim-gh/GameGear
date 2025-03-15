import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:game_gear/screen/authentication/login_screen.dart';
import 'package:game_gear/screen/authentication/signup_screen.dart';
import 'package:game_gear/screen/basket/basket_screen.dart';
import 'package:game_gear/screen/main/main_screen.dart';
import 'package:game_gear/firebase_options.dart';
import 'package:game_gear/screen/profile/profile_screen.dart';
import 'package:game_gear/screen/search/search_screen.dart';
import 'package:game_gear/shared/utils/logger_util.dart';
import 'package:logger/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  applog('Initialize the Firebase', level: Level.info);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  applog('App starting...', level: Level.info);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Example: Directing to LoginScreen then navigating to MainScreen upon success.
      home: const LoginScreen(),
      routes: {
        'signup_screen': (context) => const SignupScreen(),
        'login_screen': (context) => const LoginScreen(),
        'main_screen': (context) => const MainScreen(uid: '0'),
        'search_screen': (context) => const SearchScreen(),
        'basket_screen': (context) => const BasketScreen(),
        'profile_screen': (context) => const ProfileScreen(),
      },
    );
  }
}
