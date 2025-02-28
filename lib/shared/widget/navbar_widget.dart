import 'package:flutter/material.dart';
import 'package:game_gear/screen/basket/basket_screen.dart';
import 'package:game_gear/screen/home/home_screen.dart';
import 'package:game_gear/screen/profile/profile_screen.dart';
import 'package:game_gear/screen/search/search_screen.dart';

class NavBarWidget extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  static const screenList = [
    HomeScreen(
      id: 0,
    ),
    SearchScreen(),
    BasketScreen(),
    ProfileScreen(),
  ];
  const NavBarWidget({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Basket',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      currentIndex: selectedIndex,
      unselectedItemColor: Colors.grey,
      selectedItemColor: Colors.black,
      onTap: (index) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => screenList[index],
          ),
        );
      },
    );
  }
}
