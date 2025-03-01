import 'package:flutter/material.dart';
import 'package:game_gear/shared/constant/app_asset.dart';
import 'package:game_gear/shared/constant/app_color.dart';
import 'package:game_gear/shared/widget/appbar_widget.dart';
import 'package:game_gear/shared/widget/navbar_widget.dart';
import 'package:game_gear/shared/widget/settingchoice_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
  });

  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final int _selectedIndex = 3;

  void _onItemTapped(int index) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: "Profile"),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            SizedBox(
              width: 70,
              height: 70,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage(AppAsset.logo),
              ),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Full Name',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  'contact.gamegear@gmail.com',
                  style: TextStyle(
                      fontSize: 15,
                      color: AppColor.greyShade,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ]),
          SizedBox(height: 20),
          Text(
            'Personal Info',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SettingChoice(
            leading: Icons.person_outline,
            title: 'Personal Info',
            onTap: () {},
          ),
          SettingChoice(
            leading: Icons.payment,
            title: 'Payment Info',
            onTap: () {},
          ),
          SizedBox(height: 24),
          Text(
            'About',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SettingChoice(
            title: 'Help Center',
            leading: Icons.help_outline_rounded,
            onTap: () {},
          ),
          SettingChoice(
            title: 'Privacy Policy',
            leading: Icons.lock_outlined,
            onTap: () {},
          ),
          SettingChoice(
            title: 'About App',
            leading: Icons.info_outlined,
            onTap: () {},
          ),
          SettingChoice(
            title: 'Terms & Conditions',
            leading: Icons.book_outlined,
            onTap: () {},
          ),
        ]),
      )),
      bottomNavigationBar: NavBarWidget(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
