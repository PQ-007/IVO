import 'package:flutter/material.dart';
import 'package:test_project/data/sqlite_db_helper.dart';

class CardMakingPage extends StatefulWidget {
  final String deckName;
  final String description;
  final String category;
  const CardMakingPage({
    super.key,
    required this.deckName,
    required this.description,
    required this.category,
  });

  @override
  State<CardMakingPage> createState() => _CardMakingPageState();
}

class _CardMakingPageState extends State<CardMakingPage> {
  final TextEditingController _frontController = TextEditingController();
  final TextEditingController _backController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _flashcards = [];

  @override
  void initState() {
    super.initState();
    _loadFlashcards();
  }

  Future<void> _loadFlashcards() async {
    final data = await _dbHelper.getFlashcards();
    setState(() {
      _flashcards = data;
    });
  }

  Future<void> _addFlashcard() async {
    if (_frontController.text.isNotEmpty && _backController.text.isNotEmpty) {
      await _dbHelper.insertFlashcard(
        _frontController.text,
        _backController.text,
      );
      _frontController.clear();
      _backController.clear();
      _loadFlashcards(); // Reload flashcards after adding
    }
  }

  Future<void> _deleteFlashcard(int id) async {
    await _dbHelper.deleteFlashcard(id);
    _loadFlashcards();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Flashcards'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _frontController,
              decoration: const InputDecoration(labelText: 'Front'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _backController,
              decoration: const InputDecoration(labelText: 'Back'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _flashcards.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(_flashcards[index]['front']),
                      subtitle: Text(_flashcards[index]['back']),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed:
                            () => _deleteFlashcard(_flashcards[index]['id']),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addFlashcard,
        child: const Icon(Icons.add),
      ),
    );
  }
}
