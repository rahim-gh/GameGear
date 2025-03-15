import 'package:flutter/material.dart';
import 'package:game_gear/screen/profile/screens/profile_info/profile_info.dart';
import 'package:game_gear/shared/constant/app_asset.dart';
import 'package:game_gear/shared/constant/app_color.dart';
import 'package:game_gear/shared/model/user_model.dart';
import 'package:game_gear/shared/service/auth_service.dart';
import 'package:game_gear/shared/service/database_service.dart';
import 'package:game_gear/shared/widget/appbar_widget.dart';
import 'package:game_gear/shared/widget/setting_choice_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final User? _user;
  bool _loading = true;

  @override
  void initState() async {
    super.initState();
    _user = await DatabaseService().getUser(AuthService().currentUser!.uid);
    _loading = false;
  }

  @override
  Widget build(BuildContext context) {
    while (_loading) {
      continue;
    }
    return Scaffold(
      appBar: AppBarWidget(title: "Profile"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      _user?.fullName ?? 'Unknown',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _user?.email ?? 'Unknown',
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
              SettingChoiceWidget(
                leading: Icons.person_outline,
                title: 'Personal Info',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) =>
                          const ProfileInfoScreen(),
                    ),
                  );
                },
              ),
              SettingChoiceWidget(
                leading: Icons.payment,
                title: 'Payment Info',
                onTap: () {},
              ),
              SizedBox(height: 24),
              Text(
                'About',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SettingChoiceWidget(
                title: 'Help Center',
                leading: Icons.help_outline_rounded,
                onTap: () {},
              ),
              SettingChoiceWidget(
                title: 'Privacy Policy',
                leading: Icons.lock_outlined,
                onTap: () {},
              ),
              SettingChoiceWidget(
                title: 'About App',
                leading: Icons.info_outlined,
                onTap: () {},
              ),
              SettingChoiceWidget(
                title: 'Terms & Conditions',
                leading: Icons.book_outlined,
                onTap: () {},
              ),
              SizedBox(height: 24),
              Text(
                'Account',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SettingChoiceWidget(
                title: 'Sign Out',
                leading: Icons.logout,
                onTap: () {
                  AuthService().signOut(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
