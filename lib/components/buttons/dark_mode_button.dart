import 'package:flutter/material.dart';
import 'package:ivo/data/notifiers.dart';

class DarkModeButton extends StatelessWidget {
  const DarkModeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
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
    );
  }
}