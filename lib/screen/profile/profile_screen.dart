import 'package:flutter/material.dart';
import 'package:game_gear/screen/profile/screens/profile_info/profile_info.dart';
import 'package:game_gear/shared/constant/app_color.dart';
import 'package:game_gear/shared/model/user_model.dart';
import 'package:game_gear/shared/service/auth_service.dart';
import 'package:game_gear/shared/service/database_service.dart';
import 'package:game_gear/shared/utils/image_base64.dart';
import 'package:game_gear/shared/widget/appbar_widget.dart';
import 'package:game_gear/shared/widget/setting_choice_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  bool _loading = true;
  Image? _userImage;

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
      _user = user;
      _userImage = ImageBase64().toImage(
        user?.imageBase64,
        name: user?.fullName ?? 'Unknown',
        fit: BoxFit.cover,
      );
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBarWidget(title: "Profile"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with profile image, full name, and email (fetched from Firebase Auth).
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: ClipOval(
                      child: _userImage,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _user?.fullName ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        AuthService().currentUser?.email ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColor.greyShade,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
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
              const SizedBox(height: 24),
              const Text(
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
              const SizedBox(height: 24),
              const Text(
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
