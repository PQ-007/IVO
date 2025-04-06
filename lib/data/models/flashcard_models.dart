import 'package:cloud_firestore/cloud_firestore.dart';

class JapaneseWord {
  String id;
  String newWordByKanji;
  String newWordPronounsation;
  String translation;
  String exampleSentence;
  String exampleSentenceTranslation;
  Timestamp createdAt;

  JapaneseWord({
    required this.id,
    required this.newWordByKanji,
    required this.newWordPronounsation,
    required this.translation,
    required this.exampleSentence,
    required this.exampleSentenceTranslation,
    required this.createdAt,
  });

  // Convert Firestore document to JapaneseWord object
  factory JapaneseWord.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return JapaneseWord(
      id: doc.id,
      newWordByKanji: data['newWordByKanji'] ?? '',
      newWordPronounsation: data['newWordPronounsation'] ?? '',
      translation: data['translation'] ?? '',
      exampleSentence: data['exampleSentence'] ?? '',
      exampleSentenceTranslation: data['exampleSentenceTranslation'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  // Convert JapaneseWord object to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'newWordByKanji': newWordByKanji,
      'newWordPronounsation': newWordPronounsation,
      'translation': translation,
      'exampleSentence': exampleSentence,
      'exampleSentenceTranslation': exampleSentenceTranslation,
      'createdAt': createdAt,
    };
  }
}
