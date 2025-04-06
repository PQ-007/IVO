import 'package:flutter/material.dart';
import 'package:test_project/components/my_card.dart';
import 'package:test_project/view/pages/add_page/create_deck/add_deck_page.dart';
import 'package:test_project/view/pages/add_page/create_deck/generate_deck_page.dart';
import 'package:test_project/view/pages/card_making_page.dart';

class CreateDeckPage extends StatefulWidget {
  const CreateDeckPage({super.key});

  @override
  State<CreateDeckPage> createState() => _CreateDeckPageState();
}

class _CreateDeckPageState extends State<CreateDeckPage> {
  final TextEditingController _deckNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedCategory = 'New word';

  @override
  void dispose() {
    _deckNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _createDeck() {
    String deckName = _deckNameController.text.trim();
    String description = _descriptionController.text.trim();

    if (deckName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deck name cannot be empty')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Deck "$deckName" created in $_selectedCategory')),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                CardMakingPage(deckName: deckName, description: description),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Deck")),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            TextField(
              controller: _deckNameController,
              decoration: const InputDecoration(
                labelText: 'Deck Name',
                border: OutlineInputBorder(
                  gapPadding: 10,
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(
                  gapPadding: 10,
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Our flashcard can make japanese new words right now",
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              spacing: 10,
              children: [
                MyCard(
                  title: "Generate Deck",
                  icon: Icons.arrow_back,
                  color: Colors.green,
                  height: 150,
                  width: 180,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => GenerateDeckPage()),
                    );
                  },
                ),
                MyCard(
                  title: "Manaully Add",
                  icon: Icons.arrow_forward,
                  color: Colors.blue,
                  height: 150,
                  width: 180,
                  onTap: () {
                    // _createDeck();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AddDeckPage()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
