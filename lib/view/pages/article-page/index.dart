import 'package:flutter/material.dart';
import 'package:ivo/components/common/app_bar.dart';
import 'package:ivo/components/buttons/dark_mode_button.dart';
import 'package:ivo/components/buttons/settings_nav_button.dart';

class ArticlePage extends StatelessWidget {
  const ArticlePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        titleText: "Нийтлэл",
        button2: DarkModeButton(),
        button1: SettingsNavButton(),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [Text("Article Page")],
        ),
      ),
    );
  }
}
