import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../data/models/flashcard_models.dart';

class JapaneseWordsDeckScreen extends StatelessWidget {
  final CollectionReference wordsCollection = FirebaseFirestore.instance
      .collection('japaneseWords');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Japanese Words Deck')),
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

          return PageView.builder(
            itemCount: words.length,
            itemBuilder: (context, index) {
              final word = words[index];
              return Card(
                margin: EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        word.newWordByKanji,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Pronunciation: ${word.newWordPronounsation}',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Translation: ${word.translation}',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Example: ${word.exampleSentence}',
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Meaning: ${word.exampleSentenceTranslation}',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
