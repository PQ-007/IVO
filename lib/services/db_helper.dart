import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static Database? _kanjiDb;
  static Database? _expDb;

  // Initialize both databases
  static Future<void> init() async {
    _kanjiDb = await _initDatabase('kanji.db');
    _expDb = await _initDatabase('jmdict.db');
  }

  static Future<Database> _initDatabase(String dbName) async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, dbName);

    // Copy from assets if not exists
    if (!await File(path).exists()) {
      final data = await rootBundle.load('assets/databases/$dbName');
      final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes, flush: true);
    }

    return await openDatabase(path, readOnly: true);
  }

  // Query JMdict entries (expressions)
  static Future<List<Map<String, dynamic>>> searchWord(String keyword) async {
    if (_expDb == null) throw Exception("Expressions DB not initialized.");
    return await _expDb!.rawQuery('''
      SELECT entry.id, GROUP_CONCAT(DISTINCT gloss.content) AS glosses
      FROM entry
      JOIN sense ON entry.id = sense.id_entry
      JOIN gloss ON gloss.id_sense = sense.id
      WHERE gloss.content LIKE ? OR entry.id IN (
        SELECT id_entry FROM r_ele WHERE reb LIKE ?)
      GROUP BY entry.id
      LIMIT 30;
    ''', ['%$keyword%', '%$keyword%']);
  }

  // Query Kanji details
  static Future<Map<String, dynamic>?> getKanji(String kanji) async {
    if (_kanjiDb == null) throw Exception("Kanji DB not initialized.");
    final result = await _kanjiDb!.rawQuery('''
      SELECT character.id, character.stroke_count,
             GROUP_CONCAT(DISTINCT on_yomi.reading) AS on_yomi,
             GROUP_CONCAT(DISTINCT kun_yomi.reading) AS kun_yomi,
             GROUP_CONCAT(DISTINCT meaning.content) AS meanings
      FROM character
      LEFT JOIN on_yomi ON on_yomi.id_kanji = character.id
      LEFT JOIN kun_yomi ON kun_yomi.id_kanji = character.id
      LEFT JOIN meaning ON meaning.id_character = character.id
      WHERE character.id = ?
      GROUP BY character.id;
    ''', [kanji]);

    return result.isNotEmpty ? result.first : null;
  }

  // Close all
  static Future<void> close() async {
    await _kanjiDb?.close();
    await _expDb?.close();
    _kanjiDb = null;
    _expDb = null;
  }
}
