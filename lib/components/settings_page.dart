import 'package:flutter/material.dart';
import 'package:test_project/data/notifiers.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        leading: BackButton(onPressed: () => Navigator.pop(context)),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            ValueListenableBuilder<bool>(
              valueListenable: isDarkThemeNotifier,
              builder: (context, isDark, _) {
                return ListTile(
                  title: Text("Dark Mode"),
                  trailing: Switch(
                    value: isDark,
                    onChanged: (value) {
                      isDarkThemeNotifier.value = value;
                    },
                  ),
                );
              },
            ),
            ListTile(
              title: Text("Notifications"),
              trailing: Switch(
                value: true, // Replace with a notifier too if needed
                onChanged: (value) {
                  // Handle notification toggle
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
