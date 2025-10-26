import 'package:flutter/material.dart';
import 'package:ivo/components/MyAppbarr.dart';

class DictionaryPage extends StatelessWidget {
  const DictionaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(titleText: "Толь бичиг"),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [Text("Dictionary Page")],
        ),
      ),
    );
  }
}
