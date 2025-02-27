import 'package:flutter/material.dart';
import 'package:game_gear/shared/utils/logger_util.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:logger/web.dart';
import 'screen/authetication/login_screen.dart';
import 'screen/authetication/signup_screen.dart';
import 'package:game_gear/shared/model/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  applog('Initialize the Hive db', level: Level.info);
  await Hive.initFlutter();

  Hive.registerAdapter(UserAdapter());

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
