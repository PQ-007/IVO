import 'package:flutter/material.dart';

class AddDeckPage extends StatefulWidget {
  final String deckName;
  final String deckType;

  const AddDeckPage({
    super.key,
    required this.deckName,
    required this.deckType,
  });

  @override
  State<AddDeckPage> createState() => _AddDeckPageState();
}

class _AddDeckPageState extends State<AddDeckPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.deckName)),
      body: Center(
        child: Text(
          'Deck Type: ${widget.deckType}',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
