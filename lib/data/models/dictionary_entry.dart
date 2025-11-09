// File: lib/models/dictionary_entry.dart
class DictionaryEntry {
  final String word;
  final String reading;
  final String meaning;
  final String type;
  final List<String> examples;

  const DictionaryEntry({
    required this.word,
    required this.reading,
    required this.meaning,
    required this.type,
    required this.examples,
  });
}
