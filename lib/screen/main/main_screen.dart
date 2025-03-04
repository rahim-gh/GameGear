/// MainScreen is a stateful widget that serves as the main entry point for the app's primary screens.
/// It includes a bottom navigation bar to switch between different screens: Home, Search, Basket, and Profile.
///
/// The widget takes a required `uid` parameter which represents the user's unique identifier.
///
/// The `_MainScreenState` class manages the state of the MainScreen, including the currently selected
/// index of the bottom navigation bar and the corresponding screen to display.
///
/// The `_widgetOptions` list centralizes the different screens as widgets, and the `_onItemTapped`
/// method updates the selected index when a navigation item is tapped.
///
/// The `build` method constructs the UI, which includes a `Scaffold` to display the selected screen
/// and a `NavBarWidget` positioned at the bottom for navigation.
library;

import 'package:flutter/material.dart';
import 'package:game_gear/screen/home/home_screen.dart';
import 'package:game_gear/screen/search/search_screen.dart';
import 'package:game_gear/screen/basket/basket_screen.dart';
import 'package:game_gear/screen/profile/profile_screen.dart';
import 'package:game_gear/shared/widget/navbar_widget.dart';

class MainScreen extends StatefulWidget {
  final String uid;
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
        const HomeScreen(),
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
