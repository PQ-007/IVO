import 'package:flutter/material.dart';
import 'package:ivo/components/MyAppbarr.dart';

class ArticlePage extends StatelessWidget {
  const ArticlePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(titleText: "Нийтлэл"),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [Text("Article Page")],
        ),
      ),
    );
  }
}
