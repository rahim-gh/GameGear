import 'package:flutter/material.dart';
import 'package:game_gear/shared/service/database_service.dart';

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
      bottomNavigationBar: BottomNavigationBar(
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
            icon: Icon(Icons.shopping_basket),
            label: 'Basket',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        backgroundColor: Colors.black,
        currentIndex: _selectedIndex,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }
}
