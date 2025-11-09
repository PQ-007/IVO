import 'package:flutter/material.dart';
import 'package:ivo/components/common/app_bar.dart';
import 'package:ivo/components/buttons/dark_mode_button.dart';
import 'package:ivo/components/buttons/settings_nav_button.dart';
import 'package:ivo/components/my_recent.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

void onSearch(String query) {
  print("Searching for: $query");
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(titleText: "Нүүр", button1: DarkModeButton(), button2: SettingsNavButton(),),
      body: SingleChildScrollView(
        child: Column(
          children: [
            
            const SizedBox(height: 20),
            
            const SizedBox(height: 20),
            MyRecent(recentItems: ['a', 'ok', 'l'], type: 'flashcard'),
          ],
        ),
      ),
    );
  }
}
