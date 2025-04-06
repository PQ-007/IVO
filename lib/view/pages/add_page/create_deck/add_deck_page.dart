import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../data/models/flashcard_models.dart';

class AddDeckPage extends StatelessWidget {
  final CollectionReference wordsCollection = FirebaseFirestore.instance
      .collection('japaneseWords');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Japanese Words')),
      body: StreamBuilder(
        stream:
            wordsCollection.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No words found'));
          }

          var words =
              snapshot.data!.docs
                  .map((doc) => JapaneseWord.fromFirestore(doc))
                  .toList();

          return ListView.builder(
            itemCount: words.length,
            itemBuilder: (context, index) {
              final word = words[index];
              return ListTile(
                title: Text(
                  word.newWordByKanji,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pronunciation: ${word.newWordPronounsation}'),
                    Text('Translation: ${word.translation}'),
                    Text('Example: ${word.exampleSentence}'),
                    Text('Meaning: ${word.exampleSentenceTranslation}'),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => wordsCollection.doc(word.id).delete(),
                ),
                onTap: () => _showAddEditWordSheet(context, word: word),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showAddEditWordSheet(context),
      ),
    );
  }

  void _showAddEditWordSheet(BuildContext context, {JapaneseWord? word}) {
    TextEditingController kanjiController = TextEditingController(
      text: word?.newWordByKanji ?? '',
    );
    TextEditingController pronunciationController = TextEditingController(
      text: word?.newWordPronounsation ?? '',
    );
    TextEditingController translationController = TextEditingController(
      text: word?.translation ?? '',
    );
    TextEditingController exampleController = TextEditingController(
      text: word?.exampleSentence ?? '',
    );
    TextEditingController exampleTranslationController = TextEditingController(
      text: word?.exampleSentenceTranslation ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: kanjiController,
                decoration: InputDecoration(labelText: 'Kanji'),
              ),
              TextField(
                controller: pronunciationController,
                decoration: InputDecoration(labelText: 'Pronunciation'),
              ),
              TextField(
                controller: translationController,
                decoration: InputDecoration(labelText: 'Translation'),
              ),
              TextField(
                controller: exampleController,
                decoration: InputDecoration(labelText: 'Example Sentence'),
              ),
              TextField(
                controller: exampleTranslationController,
                decoration: InputDecoration(labelText: 'Example Translation'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                child: Text(word == null ? 'Add Word' : 'Update Word'),
                onPressed: () {
                  final newWord = JapaneseWord(
                    id: word?.id ?? wordsCollection.doc().id,
                    newWordByKanji: kanjiController.text,
                    newWordPronounsation: pronunciationController.text,
                    translation: translationController.text,
                    exampleSentence: exampleController.text,
                    exampleSentenceTranslation:
                        exampleTranslationController.text,
                    createdAt: word?.createdAt ?? Timestamp.now(),
                  );

                  wordsCollection.doc(newWord.id).set(newWord.toMap());
                  Navigator.pop(context);
                },
              ),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
