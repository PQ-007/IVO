import 'package:flutter/material.dart';
import 'package:ivo/view/pages/tool-page/settings_page.dart'; // Import your SettingsPage

class SettingsNavButton extends StatelessWidget {
  const SettingsNavButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.settings),
      onPressed: () {
        // Navigate to the settings page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SettingsPage()),
        );
      },
    );
  }
}
