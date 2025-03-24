import 'package:flutter/material.dart';
import 'package:game_gear/shared/constant/app_theme.dart';
import 'package:game_gear/shared/service/auth_service.dart';

import '../../shared/model/user_model.dart';
import '../../shared/service/database_service.dart';
import '../../shared/widget/navbar_widget.dart';
import '../basket/basket_screen.dart';
import '../home/home_screen.dart';
import '../product/screens/add_product_screen.dart';
import '../profile/profile_screen.dart';
import '../search/search_screen.dart';
import 'logic/nav_bar_visibility_controller.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final String uid = AuthService().currentUser!.uid;
  final NavBarVisibilityController _navBarController =
      NavBarVisibilityController();
  int _selectedIndex = 0;

  // Initialize _userFuture directly during declaration.
  final Future<User?> _userFuture =
      DatabaseService().getUser(AuthService().currentUser!.uid);

  /// Build the list of screens based on the user's role.
  List<Widget> _buildWidgetOptions(User user) {
    if (user.isShopOwner) {
      return [
        const HomeScreen(), // Shop owner's own products.
        const SearchScreen(), // Search his own products.
        const AddProductScreen(), // Add new product.
        const ProfileScreen(), // Profile.
      ];
    } else {
      return [
        const HomeScreen(), // View all products.
        const SearchScreen(), // Search products.
        const BasketScreen(), // Basket.
        const ProfileScreen(), // Profile.
      ];
    }
  }

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
    return FutureBuilder<User?>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Display a loading indicator while fetching user data.
          return Scaffold(
            backgroundColor: AppTheme.primaryColor,
            body: const Center(child: CircularProgressIndicator()),
            bottomNavigationBar: const SizedBox.shrink(),
          );
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            backgroundColor: AppTheme.primaryColor,
            body: const Center(
              child: Text(
                'Error loading user data',
              ),
            ),
            bottomNavigationBar: const SizedBox.shrink(),
          );
        }
        final user = snapshot.data!;
        final widgetOptions = _buildWidgetOptions(user);

        return Scaffold(
          backgroundColor: AppTheme.primaryColor,
          body: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollUpdateNotification) {
                _navBarController.onScroll(notification.metrics.pixels);
              }
              return false;
            },
            child: widgetOptions[_selectedIndex],
          ),
          bottomNavigationBar: AnimatedBuilder(
            animation: _navBarController,
            builder: (context, child) {
              return AnimatedSlide(
                duration: const Duration(milliseconds: 100),
                offset: _navBarController.isVisible
                    ? Offset.zero
                    : const Offset(0, 1),
                child: child,
              );
            },
            child: NavBarWidget(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
              user: user,
            ),
          ),
        );
      },
    );
  }
}
