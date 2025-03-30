import 'package:flutter/material.dart';
import 'package:test_project/data/notifiers.dart';
import 'package:test_project/view/pages/settings_page.dart'; // Import your SettingsPage

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titleText; // Add a field for the title

  const MyAppBar({super.key, required this.titleText}); // Constructor with titleText

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(titleText), // Use titleText here
      actions: [
        // Dark mode toggle button
        IconButton(
          onPressed: () {
            // Toggle the dark theme
            isDarkThemeNotifier.value = !isDarkThemeNotifier.value;
          },
          icon: ValueListenableBuilder(
            valueListenable: isDarkThemeNotifier,
            builder: (context, isDarkMode, child) {
              return Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode);
            },
          ),
        ),
        // Settings page navigation
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {
            // Navigate to the settings page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SettingsPage(),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight); // AppBar height
}
