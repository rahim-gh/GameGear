import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'firebase_options.dart';
import 'screen/authentication/login_screen.dart';
import 'screen/authentication/signup_screen.dart';
import 'screen/basket/basket_screen.dart';
import 'screen/direction/direction_screen.dart';
import 'screen/main/main_screen.dart';
import 'screen/profile/profile_screen.dart';
import 'screen/search/search_screen.dart';
import 'shared/utils/logger_util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  logs('Initialize the Firebase', level: Level.info);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  logs('App starting...', level: Level.info);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Example: Directing to LoginScreen then navigating to MainScreen upon success.
      // home: const LoginScreen(),
      routes: {
        '/': (context) => const DirectionScreen(),
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
