// File: lib/data/dictionary_data.dart
import 'package:ivo/data/models/dictionary_entry.dart';

class DictionaryData {
  static final List<DictionaryEntry> entries = [
    const DictionaryEntry(
      word: '学習',
      reading: 'がくしゅう',
      meaning: 'study, learning',
      type: 'noun',
      examples: ['日本語を学習する', 'Study Japanese'],
    ),
    const DictionaryEntry(
      word: '辞書',
      reading: 'じしょ',
      meaning: 'dictionary',
      type: 'noun',
      examples: ['辞書を引く', 'Look up in a dictionary'],
    ),
    const DictionaryEntry(
      word: '書く',
      reading: 'かく',
      meaning: 'to write, to draw',
      type: 'verb',
      examples: ['手紙を書く', 'Write a letter'],
    ),
    const DictionaryEntry(
      word: '読む',
      reading: 'よむ',
      meaning: 'to read',
      type: 'verb',
      examples: ['本を読む', 'Read a book'],
    ),
    const DictionaryEntry(
      word: '話す',
      reading: 'はなす',
      meaning: 'to speak, to talk',
      type: 'verb',
      examples: ['日本語を話す', 'Speak Japanese'],
    ),
    const DictionaryEntry(
      word: '聞く',
      reading: 'きく',
      meaning: 'to listen, to hear',
      type: 'verb',
      examples: ['音楽を聞く', 'Listen to music'],
    ),
  ];
}
