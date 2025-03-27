import 'package:flutter/material.dart';

import '../constant/app_theme.dart';
import '../model/user_model.dart';

class NavBarWidget extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  final User user;

  const NavBarWidget({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.user,
  });

  List<BottomNavigationBarItem> _buildNavItems() {
    if (user.isShopOwner) {
      return [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
          backgroundColor: AppTheme.accentColor,
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
          backgroundColor: AppTheme.accentColor,
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.add),
          label: 'Add',
          backgroundColor: AppTheme.accentColor,
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
          backgroundColor: AppTheme.accentColor,
        ),
      ];
    } else {
      return [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
          backgroundColor: AppTheme.accentColor,
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
          backgroundColor: AppTheme.accentColor,
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.shopping_basket),
          label: 'Basket',
          backgroundColor: AppTheme.accentColor,
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
          backgroundColor: AppTheme.accentColor,
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AppTheme.accentColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BottomNavigationBar(
          elevation: 0,
          items: _buildNavItems(),
          currentIndex: selectedIndex,
          unselectedItemColor: AppTheme.greyShadeColor,
          selectedItemColor: AppTheme.primaryColor,
          onTap: onItemTapped,
          type: BottomNavigationBarType.shifting,
        ),
      ),
    );
  }
}
