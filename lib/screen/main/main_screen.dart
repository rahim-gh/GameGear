import 'package:flutter/material.dart';
import 'package:game_gear/screen/home/home_screen.dart';
import 'package:game_gear/screen/search/search_screen.dart';
import 'package:game_gear/screen/basket/basket_screen.dart';
import 'package:game_gear/screen/profile/profile_screen.dart';
import 'package:game_gear/shared/widget/navbar_widget.dart';

class MainScreen extends StatefulWidget {
  final String uid; // Pass additional data if needed
  const MainScreen({
    super.key,
    required this.uid,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Centralize the screens as a widget list
  List<Widget> get _widgetOptions => [
        HomeScreen(uid: widget.uid),
        const SearchScreen(),
        const BasketScreen(),
        const ProfileScreen(),
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: _widgetOptions[_selectedIndex],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: NavBarWidget(
            selectedIndex: _selectedIndex,
            onItemTapped: _onItemTapped,
          ),
        ),
      ],
    );
  }
}
