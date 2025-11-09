import 'package:flutter/material.dart';

class GenerateDeckPage extends StatefulWidget {
  const GenerateDeckPage({super.key});

  @override
  State<GenerateDeckPage> createState() => _GenerateDeckPageState();
}

class _GenerateDeckPageState extends State<GenerateDeckPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Generate Deck")));
  }
}
