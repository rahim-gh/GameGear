import 'package:flutter/material.dart';
import 'package:game_gear/shared/widget/navbar_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
  });

  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 3;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage(
                      'assets/images/logo.png'), // Add your image asset
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: Text(
                  'Full Name',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Center(
                child: Text(
                  'contact.gamegear@gmail.com',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Personal Info',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ListTile(
                title: Text('Personal Data'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
              ListTile(
                title: Text('Payment Info'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
              SizedBox(height: 24),
              Text(
                'About',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ListTile(
                title: Text('Help Center'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
              ListTile(
                title: Text('Privacy Policy'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
              ListTile(
                title: Text('About App'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
              ListTile(
                title: Text('Terms & Conditions'),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavBarWidget(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
