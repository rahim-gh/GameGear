import 'package:flutter/material.dart';

import '../../shared/model/user_model.dart';
import '../../shared/service/auth_service.dart';
import '../../shared/service/database_service.dart';
import '../../shared/widget/navbar_widget.dart';
import '../basket/basket_screen.dart';
import '../home/home_screen.dart';
import '../product/screens/add_product_screen.dart';
import '../profile/profile_screen.dart';
import '../search/search_screen.dart';
import 'logic/nav_bar_visibility_controller.dart';

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
  late User _user;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    // Fetch non-sensitive user data from Firestore.
    final user =
        await DatabaseService().getUser(AuthService().currentUser!.uid);

    setState(() {
      _user = user!;
    });
  }

  int _selectedIndex = 0;
  final NavBarVisibilityController _navBarController =
      NavBarVisibilityController();

  // List of screens.
  List<Widget> get _widgetOptions => [
        const HomeScreen(),
        const SearchScreen(),
        if (_user.isShopOwner) const AddProductScreen(),
        const BasketScreen(),
        const ProfileScreen(),
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    _navBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          // Wrap the screen content with a NotificationListener.
          body: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollUpdateNotification) {
                _navBarController.onScroll(notification.metrics.pixels);
              }
              return false;
            },
            child: _widgetOptions[_selectedIndex],
          ),
        ),
        // Animate the nav bar based on the controller's visibility state.
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AnimatedBuilder(
            animation: _navBarController,
            builder: (context, child) {
              return AnimatedSlide(
                duration: const Duration(milliseconds: 100),
                // Slide out of view when hidden.
                offset: _navBarController.isVisible
                    ? Offset.zero
                    : const Offset(0, 1),
                child: child,
              );
            },
            child: NavBarWidget(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
              user: _user,
            ),
          ),
        ),
      ],
    );
  }
}
