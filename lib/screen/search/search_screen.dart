import 'package:flutter/material.dart';
import 'package:game_gear/shared/widget/appbar_widget.dart';
import 'package:game_gear/shared/widget/navbar_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
  });
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  int _selectedIndex = 1;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: "Search"),
      
      bottomNavigationBar: NavBarWidget(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
