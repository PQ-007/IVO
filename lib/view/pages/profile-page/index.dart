import 'package:flutter/material.dart';
import 'package:ivo/components/app_bar.dart';
import 'package:ivo/components/buttons/dark_mode_button.dart';
import 'package:ivo/components/buttons/settings_nav_button.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        titleText: "Profile",
        button1: DarkModeButton(),
        button2: SettingsNavButton(),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [Text("Profile Page")],
        ),
      ),
    );
  }
}
