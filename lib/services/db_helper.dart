import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class JishoDB {
  static Database? _wordDb;
  static Database? _kanjiDb;

  static Future<void> init() async {
    _wordDb = await _initDatabase('jmdict.db');
    _kanjiDb = await _initDatabase('kanji.db');
  }

  static Future<Database> _initDatabase(String dbName) async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, dbName);

    final file = File(path);
    final exists = await file.exists();

    if (!exists) {
      final data = await rootBundle.load('assets/db/$dbName');
      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      await file.writeAsBytes(bytes, flush: true);
      print('Copied $dbName from assets');
    }

    return openDatabase(path, readOnly: false);
  }

  /// Universal search (Takoboto-style)
  static Future<Map<String, dynamic>> search(String input) async {
    if (input.trim().isEmpty) return {'type': 'empty', 'result': []};

    final trimmed = input.trim();

    // Single kanji character lookup
    if (_isSingleKanji(trimmed)) {
      final kanji = await _searchKanji(trimmed);
      return {
        'type': 'kanji',
        'result': kanji != null ? [kanji] : [],
      };
    }

    // Convert romaji to hiragana if needed
    String searchQuery = trimmed;
    if (_shouldConvertRomaji(trimmed)) {
      searchQuery = _romajiToHiragana(trimmed);
      print('Converted "$trimmed" → "$searchQuery"');
    }

    // Determine search type and execute
    final words = await _searchWords(searchQuery, trimmed);
    return {'type': 'word', 'result': words};
  }

  /// Main word search with Takoboto-style prioritization
  static Future<List<Map<String, dynamic>>> _searchWords(
    String query,
    String originalQuery,
  ) async {
    final db = _wordDb!;

    final Set<int> seenIds = {};
    final List<Map<String, dynamic>> results = [];

    void addResult(Map<String, dynamic>? entry) {
      if (entry != null && !seenIds.contains(entry['id'])) {
        seenIds.add(entry['id'] as int);
        results.add(entry);
      }
    }

    // For Japanese input (kanji, hiragana, katakana)
    if (_isJapanese(query)) {
      await _searchJapanese(db, query, addResult, seenIds);
    }

    // For English input
    if (!_isJapanese(originalQuery)) {
      await _searchEnglish(db, originalQuery, addResult, seenIds);
    }

    return results;
  }

  /// Search in Japanese (kanji, hiragana, katakana)
  static Future<void> _searchJapanese(
    Database db,
    String query,
    Function(Map<String, dynamic>?) addResult,
    Set<int> seenIds,
  ) async {
    try {
      // Priority 1: EXACT match (kanji or reading)
      final exactMatches = await db.rawQuery(
        '''
        SELECT 
          entry.id AS entry_id,
          sense.id AS sense_id
        FROM entry
          JOIN r_ele ON entry.id = r_ele.id_entry
          JOIN sense ON entry.id = sense.id_entry
          LEFT JOIN k_ele ON entry.id = k_ele.id_entry
        WHERE r_ele.reb = ? OR k_ele.keb = ?
        GROUP BY entry.id, sense.id
        ORDER BY entry.id, sense.id
        LIMIT 20
      ''',
        [query, query],
      );

      for (var row in exactMatches) {
        final entryId = row['entry_id'] as int;
        if (!seenIds.contains(entryId)) {
          addResult(await _getEntryDetails(entryId));
        }
      }

      // Priority 2: STARTS WITH (kanji or reading)
      if (seenIds.length < 30) {
        final startsWithMatches = await db.rawQuery(
          '''
          SELECT 
            entry.id AS entry_id,
            MIN(LENGTH(COALESCE(k_ele.keb, r_ele.reb))) as min_length
          FROM entry
            JOIN r_ele ON entry.id = r_ele.id_entry
            LEFT JOIN k_ele ON entry.id = k_ele.id_entry
          WHERE r_ele.reb LIKE ? OR k_ele.keb LIKE ?
          GROUP BY entry.id
          ORDER BY min_length, entry.id
          LIMIT 30
        ''',
          ['$query%', '$query%'],
        );

        for (var row in startsWithMatches) {
          final entryId = row['entry_id'] as int;
          if (!seenIds.contains(entryId)) {
            addResult(await _getEntryDetails(entryId));
          }
        }
      }

      // Priority 3: CONTAINS (kanji or reading)
      if (seenIds.length < 30) {
        final containsMatches = await db.rawQuery(
          '''
          SELECT 
            entry.id AS entry_id,
            MIN(LENGTH(COALESCE(k_ele.keb, r_ele.reb))) as min_length
          FROM entry
            JOIN r_ele ON entry.id = r_ele.id_entry
            LEFT JOIN k_ele ON entry.id = k_ele.id_entry
          WHERE r_ele.reb LIKE ? OR k_ele.keb LIKE ?
          GROUP BY entry.id
          ORDER BY min_length, entry.id
          LIMIT 30
        ''',
          ['%$query%', '%$query%'],
        );

        for (var row in containsMatches) {
          final entryId = row['entry_id'] as int;
          if (!seenIds.contains(entryId)) {
            addResult(await _getEntryDetails(entryId));
          }
        }
      }
    } catch (e) {
      print('Error in Japanese search: $e');
    }
  }

  /// Search in English
  static Future<void> _searchEnglish(
    Database db,
    String query,
    Function(Map<String, dynamic>?) addResult,
    Set<int> seenIds,
  ) async {
    try {
      final lowerQuery = query.toLowerCase();

      // Priority 1: Exact gloss match
      final exactGloss = await db.rawQuery(
        '''
        SELECT DISTINCT entry.id AS entry_id
        FROM entry
          JOIN sense ON entry.id = sense.id_entry
          JOIN gloss ON gloss.id_sense = sense.id
        WHERE LOWER(gloss.content) = ?
        ORDER BY entry.id
        LIMIT 20
      ''',
        [lowerQuery],
      );

      for (var row in exactGloss) {
        final entryId = row['entry_id'] as int;
        if (!seenIds.contains(entryId)) {
          addResult(await _getEntryDetails(entryId));
        }
      }

      // Priority 2: Starts with
      if (seenIds.length < 30) {
        final startsWithGloss = await db.rawQuery(
          '''
          SELECT DISTINCT entry.id AS entry_id
          FROM entry
            JOIN sense ON entry.id = sense.id_entry
            JOIN gloss ON gloss.id_sense = sense.id
          WHERE LOWER(gloss.content) LIKE ?
          ORDER BY entry.id
          LIMIT 25
        ''',
          ['$lowerQuery%'],
        );

        for (var row in startsWithGloss) {
          final entryId = row['entry_id'] as int;
          if (!seenIds.contains(entryId)) {
            addResult(await _getEntryDetails(entryId));
          }
        }
      }

      // Priority 3: Contains
      if (seenIds.length < 30) {
        final containsGloss = await db.rawQuery(
          '''
          SELECT DISTINCT entry.id AS entry_id
          FROM entry
            JOIN sense ON entry.id = sense.id_entry
            JOIN gloss ON gloss.id_sense = sense.id
          WHERE LOWER(gloss.content) LIKE ?
          ORDER BY entry.id
          LIMIT 30
        ''',
          ['%$lowerQuery%'],
        );

        for (var row in containsGloss) {
          final entryId = row['entry_id'] as int;
          if (!seenIds.contains(entryId)) {
            addResult(await _getEntryDetails(entryId));
          }
        }
      }
    } catch (e) {
      print('Error in English search: $e');
    }
  }

  /// Get full entry details with all senses
  static Future<Map<String, dynamic>?> _getEntryDetails(int entryId) async {
    final db = _wordDb!;

    try {
      // Get all kanji forms
      final kanjiList = await db.rawQuery(
        'SELECT keb FROM k_ele WHERE id_entry = ? ORDER BY id',
        [entryId],
      );

      // Get all reading forms
      final readingList = await db.rawQuery(
        'SELECT reb FROM r_ele WHERE id_entry = ? ORDER BY id',
        [entryId],
      );

      // Get all senses with their data
      final senses = await db.rawQuery(
        'SELECT DISTINCT id FROM sense WHERE id_entry = ? ORDER BY id',
        [entryId],
      );

      if (kanjiList.isEmpty && readingList.isEmpty) return null;

      List<Map<String, dynamic>> sensesWithDetails = [];
      for (var sense in senses) {
        final senseId = sense['id'] as int;

        // Get POS
        final posList = await db.rawQuery(
          '''
          SELECT p.name
          FROM sense_pos sp
          JOIN pos p ON p.id = sp.id_pos
          WHERE sp.id_sense = ?
        ''',
          [senseId],
        );

        // Get glosses
        final glossList = await db.rawQuery(
          'SELECT content FROM gloss WHERE id_sense = ?',
          [senseId],
        );

        // Get misc info
        final miscList = await db.rawQuery(
          '''
          SELECT m.name
          FROM sense_misc sm
          JOIN misc m ON m.id = sm.id_misc
          WHERE sm.id_sense = ?
        ''',
          [senseId],
        );

        // Get dialect info
        final dialList = await db.rawQuery(
          '''
          SELECT d.name
          FROM sense_dial sd
          JOIN dial d ON d.id = sd.id_dial
          WHERE sd.id_sense = ?
        ''',
          [senseId],
        );

        sensesWithDetails.add({
          'pos': posList.map((p) => p['name']).toList(),
          'glosses': glossList.map((g) => g['content']).toList(),
          'misc': miscList.map((m) => m['name']).toList(),
          'dial': dialList.map((d) => d['name']).toList(),
        });
      }

      return {
        'id': entryId,
        'kanji': kanjiList.map((k) => k['keb']).toList(),
        'reading': readingList.map((r) => r['reb']).toList(),
        'senses': sensesWithDetails,
      };
    } catch (e) {
      print('Error getting entry details for $entryId: $e');
      return null;
    }
  }

  /// Kanji lookup with radicals
  static Future<Map<String, dynamic>?> _searchKanji(String kanji) async {
    final db = _kanjiDb!;

    try {
      final res = await db.rawQuery(
        'SELECT * FROM character WHERE id = ? LIMIT 1',
        [kanji],
      );

      if (res.isEmpty) return null;

      final char = res.first;

      // Get radicals
      final radicals = await db.rawQuery(
        '''
        SELECT radical.*
        FROM radical
        JOIN character_radical ON character_radical.id_radical = radical.id
        WHERE character_radical.id_character = ?
        ORDER BY stroke_count
      ''',
        [kanji],
      );

      // Get readings
      final onYomi = await db.rawQuery(
        'SELECT reading FROM on_yomi WHERE id_character = ?',
        [kanji],
      );

      final kunYomi = await db.rawQuery(
        'SELECT reading FROM kun_yomi WHERE id_character = ?',
        [kanji],
      );

      // Get meanings
      final meanings = await db.rawQuery(
        'SELECT content FROM meaning WHERE id_character = ?',
        [kanji],
      );

      return {
        'character': kanji,
        'stroke_count': char['stroke_count'],
        'grade': char['grade'],
        'frequency': char['frequency'],
        'jlpt': char['jlpt'],
        'radicals':
            radicals
                .map(
                  (r) => {
                    'radical': r['id'],
                    'stroke_count': r['stroke_count'],
                  },
                )
                .toList(),
        'on_yomi': onYomi.map((r) => r['reading']).toList(),
        'kun_yomi': kunYomi.map((r) => r['reading']).toList(),
        'meanings': meanings.map((m) => m['content']).toList(),
      };
    } catch (e) {
      print('Error searching kanji: $e');
      return null;
    }
  }

  // Type detection helpers
  static bool _isSingleKanji(String s) =>
      s.length == 1 && RegExp(r'[\u4E00-\u9FFF]').hasMatch(s);

  static bool _isJapanese(String s) => RegExp(
    r'^[\u3000-\u303F\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FFF\uFF00-\uFFEF]+$',
  ).hasMatch(s);

  static bool _shouldConvertRomaji(String s) {
    // reject if it has Japanese chars
    if (_isJapanese(s)) return false;

    final lower = s.toLowerCase().trim();

    // If it contains spaces and looks like an English sentence, skip conversion
    if (RegExp(r'\s').hasMatch(lower) && lower.split(' ').length > 1) {
      return false;
    }

    // Common English words filter (keep it small)
    const englishWords = {
      'love',
      'like',
      'eat',
      'see',
      'thank',
      'apple',
      'book',
      'computer',
      'school',
      'good',
      'bad',
      'time',
      'when',
      'where',
      'who',
      'what',
      'how',
      'make',
      'go',
    };
    if (englishWords.contains(lower)) return false;

    // Romaji pattern check: only lowercase a-z and maybe apostrophes
    if (!RegExp(r"^[a-z']+$").hasMatch(lower)) return false;

    // Japanese romaji typically follow (C)V pattern: consonant + vowel
    // We'll check if the text is made mostly of such syllables.
    final syllablePattern = RegExp(
      r'^(?:[kstnhmyrwgzdbpfcjv]*[aiueo]|nn)+$',
      caseSensitive: false,
    );

    if (syllablePattern.hasMatch(lower)) {
      return true; // looks like valid romaji
    }

    // Bonus: heuristic — short words (<=4 letters) are ambiguous,
    // but if they contain Japanese-like chunks, treat as romaji.
    if (lower.length <= 4 &&
        RegExp(
          r'(ka|ki|ku|ke|ko|sa|shi|su|se|so|ta|te|to|na|ni|nu|ne|no|ha|hi|fu|he|ho|ma|mi|mu|me|mo|ya|yu|yo|ra|ri|ru|re|ro|wa|wo|nn)',
        ).hasMatch(lower)) {
      return true;
    }

    return false;
  }

  /// Romaji to hiragana conversion
  static String _romajiToHiragana(String romaji) {
    final map = {
      'kya': 'きゃ',
      'kyu': 'きゅ',
      'kyo': 'きょ',
      'sha': 'しゃ',
      'shu': 'しゅ',
      'sho': 'しょ',
      'shi': 'し',
      'cha': 'ちゃ',
      'chu': 'ちゅ',
      'cho': 'ちょ',
      'chi': 'ち',
      'nya': 'にゃ',
      'nyu': 'にゅ',
      'nyo': 'にょ',
      'hya': 'ひゃ',
      'hyu': 'ひゅ',
      'hyo': 'ひょ',
      'mya': 'みゃ',
      'myu': 'みゅ',
      'myo': 'みょ',
      'rya': 'りゃ',
      'ryu': 'りゅ',
      'ryo': 'りょ',
      'gya': 'ぎゃ',
      'gyu': 'ぎゅ',
      'gyo': 'ぎょ',
      'bya': 'びゃ',
      'byu': 'びゅ',
      'byo': 'びょ',
      'pya': 'ぴゃ',
      'pyu': 'ぴゅ',
      'pyo': 'ぴょ',
      'tsu': 'つ',
      'ka': 'か',
      'ki': 'き',
      'ku': 'く',
      'ke': 'け',
      'ko': 'こ',
      'ga': 'が',
      'gi': 'ぎ',
      'gu': 'ぐ',
      'ge': 'げ',
      'go': 'ご',
      'sa': 'さ',
      'su': 'す',
      'se': 'せ',
      'so': 'そ',
      'za': 'ざ',
      'ji': 'じ',
      'zu': 'ず',
      'ze': 'ぜ',
      'zo': 'ぞ',
      'ta': 'た',
      'te': 'て',
      'to': 'と',
      'da': 'だ',
      'di': 'ぢ',
      'du': 'づ',
      'de': 'で',
      'do': 'ど',
      'na': 'な',
      'ni': 'に',
      'nu': 'ぬ',
      'ne': 'ね',
      'no': 'の',
      'ha': 'は',
      'hi': 'ひ',
      'fu': 'ふ',
      'he': 'へ',
      'ho': 'ほ',
      'ba': 'ば',
      'bi': 'び',
      'bu': 'ぶ',
      'be': 'べ',
      'bo': 'ぼ',
      'pa': 'ぱ',
      'pi': 'ぴ',
      'pu': 'ぷ',
      'pe': 'ぺ',
      'po': 'ぽ',
      'ma': 'ま',
      'mi': 'み',
      'mu': 'む',
      'me': 'め',
      'mo': 'も',
      'ya': 'や',
      'yu': 'ゆ',
      'yo': 'よ',
      'ra': 'ら',
      'ri': 'り',
      'ru': 'る',
      're': 'れ',
      'ro': 'ろ',
      'wa': 'わ',
      'wo': 'を',
      'nn': 'ん',
      'a': 'あ',
      'i': 'い',
      'u': 'う',
      'e': 'え',
      'o': 'お',
      'n': 'ん',
    };

    String result = romaji.toLowerCase();
    final sortedKeys =
        map.keys.toList()..sort((a, b) => b.length.compareTo(a.length));

    for (var key in sortedKeys) {
      result = result.replaceAll(key, map[key]!);
    }

    return result;
  }

  static Future<void> close() async {
    await _wordDb?.close();
    await _kanjiDb?.close();
  }
}
