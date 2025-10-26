import 'package:flutter/material.dart';
import 'package:ivo/components/my_appbar.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: MyAppBar(titleText: "Library"),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text("Library Page")],
        ),
      ),
    );
  }
}
