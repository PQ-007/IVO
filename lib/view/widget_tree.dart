import 'package:flutter/material.dart';
import 'package:ivo/components/MyNavbar.dart';
import 'package:ivo/data/notifiers.dart';
import 'package:ivo/view/pages/article-page/index.dart';
import 'package:ivo/view/pages/dictionary-page/index.dart';
import 'package:ivo/view/pages/home-page/index.dart';
import 'package:ivo/view/pages/library-page/index.dart';
import 'package:ivo/view/pages/tool-page/index.dart';

List<Widget> pages = [
  HomePage(),
  DictionaryPage(),
  ToolPage(),
  ArticlePage(),
  LibraryPage(),
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
