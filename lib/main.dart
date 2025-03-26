import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'shared/constant/app_theme.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'screen/authentication/login_screen.dart';
import 'screen/authentication/signup_screen.dart';
import 'screen/basket/basket_screen.dart';
import 'screen/direction/direction_screen.dart';
import 'screen/home/home_screen.dart';
import 'screen/main/main_screen.dart';
import 'screen/profile/profile_screen.dart';
import 'screen/search/search_screen.dart';
import 'shared/model/basket_model.dart';
import 'shared/utils/logger_util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  logs('Initialize the Firebase', level: Level.info);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  logs('App starting...', level: Level.info);
  runApp(
    ChangeNotifierProvider(
      // Wrap the app with ChangeNotifierProvider
      create: (context) => BasketModel(), // Provide the BasketModel
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: AppTheme.primaryColor,
      debugShowCheckedModeBanner: false,
      // home: const LoginScreen(),
      routes: {
        '/': (context) => const DirectionScreen(),
        'signup_screen': (context) => const SignupScreen(),
        'login_screen': (context) => const LoginScreen(),
        'main_screen': (context) => const MainScreen(),
        'home_screen': (context) => const HomeScreen(),
        'search_screen': (context) => const SearchScreen(),
        'basket_screen': (context) => const BasketScreen(),
        'profile_screen': (context) => const ProfileScreen(),
      },
    );
  }
}
