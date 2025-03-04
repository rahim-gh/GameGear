// import 'package:flutter/material.dart';
// import 'package:game_gear/shared/constant/app_color.dart';

// class NavBarWidget extends StatelessWidget {
//   final int selectedIndex;
//   final ValueChanged<int> onItemTapped;
//   static const screenList = [
//     'home_screen',
//     'search_screen',
//     'basket_screen',
//     'profile_screen'
//   ];
//   const NavBarWidget({
//     super.key,
//     required this.selectedIndex,
//     required this.onItemTapped,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       items: const <BottomNavigationBarItem>[
//         BottomNavigationBarItem(
//           icon: Icon(Icons.home),
//           label: 'Home',
//           backgroundColor: AppColor.accent,
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.search),
//           label: 'Search',
//           backgroundColor: AppColor.accent,
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.shopping_cart),
//           label: 'Basket',
//           backgroundColor: AppColor.accent,
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.person),
//           label: 'Profile',
//           backgroundColor: AppColor.accent,
//         ),
//       ],
//       currentIndex: selectedIndex,
//       // type: BottomNavigationBarType.shifting,
//       backgroundColor: AppColor.accent,
//       unselectedItemColor: AppColor.greyShade,
//       selectedItemColor: AppColor.primary,
//       onTap: (index) {
//         onItemTapped(index);
//         Navigator.of(context).pushReplacementNamed(screenList[index]);
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:game_gear/shared/constant/app_color.dart';

class NavBarWidget extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const NavBarWidget({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColor.accent,
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
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
              backgroundColor: AppColor.accent,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
              backgroundColor: AppColor.accent,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Basket',
              backgroundColor: AppColor.accent,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
              backgroundColor: AppColor.accent,
            ),
          ],
          currentIndex: selectedIndex,
          unselectedItemColor: AppColor.greyShade,
          selectedItemColor: AppColor.primary,
          onTap: onItemTapped, // Delegate control to the parent widget
        ),
      ),
    );
  }
}
