import 'package:flutter/material.dart';
import 'package:game_gear/shared/constant/app_asset.dart';
import 'package:game_gear/shared/constant/app_color.dart';
import 'package:game_gear/shared/service/database_service.dart';
import 'package:game_gear/shared/widget/appbar_widget.dart';
import 'package:game_gear/shared/widget/itemcard_widget.dart';
import 'package:game_gear/shared/widget/navbar_widget.dart';

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
    final user = await DatabaseService().getUser(widget.id);
    setState(() {
      _userInfo = user.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.secondary,
      appBar: AppBarWidget(title: 'Home'),
      body: ListView.builder(
        itemCount: AppAsset.elements.length,
        itemBuilder: (context, index) {
          return ItemCard(index: index);
        },
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: NavBarWidget(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

