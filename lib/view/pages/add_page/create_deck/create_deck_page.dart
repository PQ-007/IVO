import 'package:flutter/material.dart';
import 'package:test_project/components/my_card.dart';
import 'package:test_project/view/pages/add_page/create_deck/add_deck/index.dart';
import 'package:test_project/view/pages/add_page/create_deck/generate_deck_page.dart';

class CreateDeckPage extends StatefulWidget {
  const CreateDeckPage({super.key});

  @override
  State<CreateDeckPage> createState() => _CreateDeckPageState();
}

class _CreateDeckPageState extends State<CreateDeckPage> {
  final TextEditingController _deckNameController = TextEditingController();
  String selectedValue = "Standart";
  @override
  void dispose() {
    _deckNameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Deckx")),
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

            Container(
              padding: EdgeInsets.only(left: 15, right: 5),
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  hint: const Text("Select the template of deck"),
                  value: selectedValue,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedValue = newValue!;
                    });
                  },
                  items:
                      [
                            'Kanji',
                            'New word',
                            'Theoretical',
                            'Technical',
                            'Standart',
                          ]
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                ),
              ),
            ),
            const SizedBox(height: 10),
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
                      MaterialPageRoute(
                        builder:
                            (_) => AddDeckPage(
                              deckName: _deckNameController.text,
                              deckType: selectedValue,
                            ),
                      ),
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
