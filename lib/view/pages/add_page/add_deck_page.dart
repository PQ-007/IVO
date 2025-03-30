import 'package:flutter/material.dart';
import 'package:test_project/view/pages/card_making_page.dart';

class AddDeckPage extends StatefulWidget {
  const AddDeckPage({super.key});

  @override
  State<AddDeckPage> createState() => _AddDeckPageState();
}

class _AddDeckPageState extends State<AddDeckPage> {
  final TextEditingController _deckNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedCategory = 'New word'; // Default value for dropdown

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
            (context) => CardMakingPage(
              deckName: deckName,
              description: description,
              category: _selectedCategory,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Deck")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _deckNameController,
              decoration: const InputDecoration(labelText: 'Deck Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                const Text('Type: ', style: TextStyle(fontSize: 16)),
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true, // ✅ Prevents overflow
                    value: _selectedCategory,
                    items:
                        ['New word', 'Kanji', 'Grammar', 'Classic', 'Technical']
                            .map(
                              (String value) => DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              ),
                            )
                            .toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Sample deck:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Container(height: 400, color: Colors.grey),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const TextButton(
                  onPressed: null,
                  child: Text(
                    'Generate deck from input',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: _createDeck,
                  child: const Text(
                    'Manually make deck',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
