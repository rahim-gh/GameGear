import 'package:flutter/material.dart';
import 'package:game_gear/shared/service/database_service.dart';
import 'package:game_gear/shared/utils/logger_util.dart';
import 'package:game_gear/shared/widget/navbar_widget.dart';
import 'package:logger/logger.dart';

class HomeScreen extends StatefulWidget {
  final int id;

  const HomeScreen({
    super.key,
    required this.id,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    Center(
      child: Text(
        'Home Page',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    ),
    Center(
      child: Text(
        'Search Page',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    ),
    Center(
      child: Text(
        'Basket Page',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    ),
    Center(
      child: Text(
        'Profile Page',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  String _userInfo = '';

  Future<void> _loadUserData() async {
    try {
      // Fetch the user data
      final user = await DatabaseService().getUser(widget.id);
      if (user == null) {
        setState(() {
          _userInfo = "User not found.";
        });
        return;
      }

      // Start building the display string with user details
      String userData = "User: ${user.toString()}";

      // If the user is a shop owner, fetch their products
      if (user.isShopOwner) {
        final products =
            await DatabaseService().getProductsForShopOwner(user.id);
        userData += "\n\nProducts:\n";
        if (products.isEmpty) {
          userData += "No products found.";
        } else {
          for (final product in products) {
            userData += "$product\n";
          }
        }
      }

      // Update the state with the aggregated information
      setState(() {
        _userInfo = userData;
      });
    } catch (e) {
      applog('Error loading user data: $e', level: Level.error);
      setState(() {
        _userInfo = "Error loading user data: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications')),
              );
            },
          ),
        ],
      ),
      body: Center(
        // child: _widgetOptions.elementAt(_selectedIndex),
        child: Text(_userInfo),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: NavBarWidget(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
