import 'package:flutter/material.dart';
import 'package:ivo/components/my_navbar.dart';
import 'package:ivo/data/notifiers.dart';
import 'package:ivo/view/pages/add_page/index.dart';
import 'package:ivo/view/pages/home_page/index.dart';
import 'package:ivo/view/pages/library_page/index.dart';
import 'package:ivo/view/pages/profile_page/index.dart';
import 'package:ivo/view/pages/stats_page/index.dart';

List<Widget> pages = [
  HomePage(),
  StatsPage(),
  AddPage(),
  LibraryPage(),
  ProfilePage(),
];

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: selectedPageNotifier,
        builder: (context, value, child) {
          return pages.elementAt(value);
        },
      ),
      bottomNavigationBar: MyNavbar(),
    );
  }
}
