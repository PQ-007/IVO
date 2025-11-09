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
    // Try to setup FTS tables (will skip if already exist or if read-only)
    await _setupFTS();
  }

  static Future<Database> _initDatabase(String dbName) async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, dbName);

    // Check if database already exists
    final file = File(path);
    final exists = await file.exists();

    if (!exists) {
      // Copy from assets only if it doesn't exist
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

  // Setup FTS tables for fast searching
  static Future<void> _setupFTS() async {
    final db = _wordDb!;

    try {
      // Check if FTS table exists
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='entry_fts'",
      );

      if (tables.isEmpty) {
        print('Creating FTS tables... This may take a minute on first run.');
        await _createFTSTables(db);
        print('FTS tables created successfully!');
      } else {
        print('FTS tables already exist.');
      }
    } catch (e) {
      print('Warning: Could not create FTS tables. Search will be slower.');
      print('Error: $e');
      // Continue anyway - we'll use fallback search methods
    }
  }

  static Future<void> _createFTSTables(Database db) async {
    await db.transaction((txn) async {
      // Create FTS5 virtual table for full-text search
      await txn.execute('''
        CREATE VIRTUAL TABLE IF NOT EXISTS entry_fts USING fts5(
          entry_id UNINDEXED,
          keb,
          reb,
          gloss,
          content=''
        )
      ''');

      print('FTS table created, now populating...');

      // Populate FTS table with ALL entries (not just 1000)
      final entries = await txn.rawQuery('SELECT DISTINCT id FROM entry');

      print('Populating FTS with ${entries.length} entries...');

      int count = 0;
      for (var entry in entries) {
        final entryId = entry['id'] as int;

        // Get kanji
        final kanjis = await txn.rawQuery(
          '''
          SELECT keb FROM k_ele WHERE id_entry = ?
        ''',
          [entryId],
        );
        final kebStr = kanjis.map((k) => k['keb']).join(' ');

        // Get readings
        final readings = await txn.rawQuery(
          '''
          SELECT reb FROM r_ele WHERE id_entry = ?
        ''',
          [entryId],
        );
        final rebStr = readings.map((r) => r['reb']).join(' ');

        // Get glosses
        final glosses = await txn.rawQuery(
          '''
          SELECT g.content
          FROM sense s
          JOIN gloss g ON g.id_sense = s.id
          WHERE s.id_entry = ?
        ''',
          [entryId],
        );
        final glossStr = glosses.map((g) => g['content']).join(' ');

        // Insert into FTS
        await txn.insert('entry_fts', {
          'entry_id': entryId,
          'keb': kebStr,
          'reb': rebStr,
          'gloss': glossStr,
        });

        count++;
        if (count % 1000 == 0) {
          print('Processed $count entries...');
        }
      }

      print('FTS population complete!');
    });
  }

  // 🔍 Universal search (Jisho-style)
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

    // Determine if this is romaji that should be converted
    String searchQuery = trimmed;
    if (_shouldConvertRomaji(trimmed)) {
      searchQuery = _romajiToHiragana(trimmed);
      print('Converted "$trimmed" → "$searchQuery"');
    }

    // Search for words/entries
    final words = await _searchWords(searchQuery, trimmed);
    return {'type': 'word', 'result': words};
  }

  // 🔎 Main word search function
  static Future<List<Map<String, dynamic>>> _searchWords(
    String query,
    String originalQuery,
  ) async {
    final db = _wordDb!;
    List<Map<String, dynamic>> results = [];

    // 1. Exact match on kanji or reading (highest priority)
    if (_isJapanese(query)) {
      try {
        final exactMatches = await db.rawQuery(
          '''
          SELECT DISTINCT e.id
          FROM entry e
          LEFT JOIN k_ele ke ON ke.id_entry = e.id
          LEFT JOIN r_ele re ON re.id_entry = e.id
          WHERE ke.keb = ? OR re.reb = ?
          LIMIT 10
        ''',
          [query, query],
        );

        for (var match in exactMatches) {
          final detailed = await _getEntryDetails(match['id'] as int);
          if (detailed != null) results.add(detailed);
        }
      } catch (e) {
        print('Exact match error: $e');
      }
    }

    // 2. Partial match on kanji or reading
    if (_isJapanese(query) && results.length < 20) {
      try {
        final partialMatches = await db.rawQuery(
          '''
          SELECT DISTINCT e.id
          FROM entry e
          LEFT JOIN k_ele ke ON ke.id_entry = e.id
          LEFT JOIN r_ele re ON re.id_entry = e.id
          WHERE ke.keb LIKE ? OR re.reb LIKE ?
          LIMIT 20
        ''',
          ['%$query%', '%$query%'],
        );

        for (var match in partialMatches) {
          if (!results.any((r) => r['id'] == match['id'])) {
            final detailed = await _getEntryDetails(match['id'] as int);
            if (detailed != null) results.add(detailed);
          }
        }
      } catch (e) {
        print('Partial match error: $e');
      }
    }

    // 3. English search - use original query for English searches
    if (results.length < 20 && !_isJapanese(originalQuery)) {
      // Check if FTS table exists
      final hasFTS = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='entry_fts'",
      );

      if (hasFTS.isNotEmpty) {
        // Use FTS5
        try {
          String ftsQuery =
              originalQuery.replaceAll(RegExp(r'[^\w\s]'), ' ').trim();

          final ftsMatches = await db.rawQuery(
            '''
            SELECT DISTINCT entry_id
            FROM entry_fts
            WHERE entry_fts MATCH ?
            LIMIT 30
          ''',
            [ftsQuery],
          );

          for (var match in ftsMatches) {
            final entryId = match['entry_id'] as int;
            if (!results.any((r) => r['id'] == entryId)) {
              final detailed = await _getEntryDetails(entryId);
              if (detailed != null) results.add(detailed);
            }
          }
        } catch (e) {
          print('FTS search failed: $e, falling back to LIKE');
        }
      }

      // Fallback: LIKE search on gloss (slower but works)
      if (results.length < 20) {
        try {
          final glossMatches = await db.rawQuery(
            '''
            SELECT DISTINCT s.id_entry as id
            FROM sense s
            JOIN gloss g ON g.id_sense = s.id
            WHERE g.content LIKE ?
            LIMIT 30
          ''',
            ['%$originalQuery%'],
          );

          for (var match in glossMatches) {
            final entryId = match['id'] as int;
            if (!results.any((r) => r['id'] == entryId)) {
              final detailed = await _getEntryDetails(entryId);
              if (detailed != null) results.add(detailed);
            }
          }
        } catch (e) {
          print('LIKE search error: $e');
        }
      }
    }

    return results;
  }

  // Get full entry details with all senses
  static Future<Map<String, dynamic>?> _getEntryDetails(int entryId) async {
    final db = _wordDb!;

    try {
      // Get kanji forms
      final kanjiList = await db.rawQuery(
        '''
        SELECT keb FROM k_ele WHERE id_entry = ?
      ''',
        [entryId],
      );

      // Get reading forms
      final readingList = await db.rawQuery(
        '''
        SELECT reb FROM r_ele WHERE id_entry = ?
      ''',
        [entryId],
      );

      // Get all senses with their glosses
      final senses = await db.rawQuery(
        '''
        SELECT DISTINCT s.id
        FROM sense s
        WHERE s.id_entry = ?
        ORDER BY s.id
      ''',
        [entryId],
      );

      if (kanjiList.isEmpty && readingList.isEmpty) return null;

      // Get details for each sense
      List<Map<String, dynamic>> sensesWithDetails = [];
      for (var sense in senses) {
        final senseId = sense['id'] as int;

        // Get POS for this sense
        final posList = await db.rawQuery(
          '''
          SELECT p.name
          FROM sense_pos sp
          JOIN pos p ON p.id = sp.id_pos
          WHERE sp.id_sense = ?
        ''',
          [senseId],
        );

        // Get glosses for this sense
        final glossList = await db.rawQuery(
          '''
          SELECT content FROM gloss WHERE id_sense = ?
        ''',
          [senseId],
        );

        sensesWithDetails.add({
          'pos': posList.map((p) => p['name']).toList(),
          'glosses': glossList.map((g) => g['content']).toList(),
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

  // 漢字 lookup
  static Future<Map<String, dynamic>?> _searchKanji(String kanji) async {
    final db = _kanjiDb!;

    try {
      // Get basic kanji info
      final res = await db.rawQuery(
        '''
        SELECT id, stroke_count
        FROM character
        WHERE id = ?
        LIMIT 1
      ''',
        [kanji],
      );

      if (res.isEmpty) return null;

      // Get readings - FIXED: use id_character instead of id_kanji
      final onYomi = await db.rawQuery(
        '''
        SELECT reading FROM on_yomi WHERE id_character = ?
      ''',
        [kanji],
      );

      final kunYomi = await db.rawQuery(
        '''
        SELECT reading FROM kun_yomi WHERE id_character = ?
      ''',
        [kanji],
      );

      // Get meanings
      final meanings = await db.rawQuery(
        '''
        SELECT content FROM meaning WHERE id_character = ?
      ''',
        [kanji],
      );

      return {
        'character': kanji,
        'stroke_count': res.first['stroke_count'],
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

  // FIXED: Better detection for when to convert romaji
  // Only convert if it looks like Japanese romaji, not English words
  static bool _shouldConvertRomaji(String s) {
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(s)) return false;

    // Common English words that shouldn't be converted
    final commonEnglish = [
      'eat',
      'thank',
      'the',
      'and',
      'for',
      'with',
      'from',
      'have',
      'this',
      'that',
      'what',
      'when',
      'where',
      'who',
      'how',
      'can',
      'will',
      'would',
      'could',
      'should',
      'about',
      'make',
      'take',
      'give',
      'think',
      'know',
      'want',
      'need',
      'like',
      'love',
      'hate',
    ];

    final lower = s.toLowerCase().trim();
    if (commonEnglish.contains(lower)) return false;

    // If it contains common Japanese romaji patterns, convert it
    // Common patterns: 'tsu', 'shi', 'chi', double consonants
    final romajiPatterns = RegExp(
      r'(tsu|shi|chi|sha|sho|chu|cha|cho|kya|kyu|kyo|ryu|nn)',
    );
    return romajiPatterns.hasMatch(lower);
  }

  // Comprehensive romaji → hiragana conversion
  static String _romajiToHiragana(String romaji) {
    final map = {
      // Three-letter combinations (must come first)
      'kya': 'きゃ', 'kyu': 'きゅ', 'kyo': 'きょ',
      'sha': 'しゃ', 'shu': 'しゅ', 'sho': 'しょ', 'shi': 'し',
      'cha': 'ちゃ', 'chu': 'ちゅ', 'cho': 'ちょ', 'chi': 'ち',
      'nya': 'にゃ', 'nyu': 'にゅ', 'nyo': 'にょ',
      'hya': 'ひゃ', 'hyu': 'ひゅ', 'hyo': 'ひょ',
      'mya': 'みゃ', 'myu': 'みゅ', 'myo': 'みょ',
      'rya': 'りゃ', 'ryu': 'りゅ', 'ryo': 'りょ',
      'gya': 'ぎゃ', 'gyu': 'ぎゅ', 'gyo': 'ぎょ',
      'bya': 'びゃ', 'byu': 'びゅ', 'byo': 'びょ',
      'pya': 'ぴゃ', 'pyu': 'ぴゅ', 'pyo': 'ぴょ',
      'tsu': 'つ',

      // Two-letter combinations
      'ka': 'か', 'ki': 'き', 'ku': 'く', 'ke': 'け', 'ko': 'こ',
      'ga': 'が', 'gi': 'ぎ', 'gu': 'ぐ', 'ge': 'げ', 'go': 'ご',
      'sa': 'さ', 'su': 'す', 'se': 'せ', 'so': 'そ',
      'za': 'ざ', 'ji': 'じ', 'zu': 'ず', 'ze': 'ぜ', 'zo': 'ぞ',
      'ta': 'た', 'te': 'て', 'to': 'と',
      'da': 'だ', 'di': 'ぢ', 'du': 'づ', 'de': 'で', 'do': 'ど',
      'na': 'な', 'ni': 'に', 'nu': 'ぬ', 'ne': 'ね', 'no': 'の',
      'ha': 'は', 'hi': 'ひ', 'fu': 'ふ', 'he': 'へ', 'ho': 'ほ',
      'ba': 'ば', 'bi': 'び', 'bu': 'ぶ', 'be': 'べ', 'bo': 'ぼ',
      'pa': 'ぱ', 'pi': 'ぴ', 'pu': 'ぷ', 'pe': 'ぺ', 'po': 'ぽ',
      'ma': 'ま', 'mi': 'み', 'mu': 'む', 'me': 'め', 'mo': 'も',
      'ya': 'や', 'yu': 'ゆ', 'yo': 'よ',
      'ra': 'ら', 'ri': 'り', 'ru': 'る', 're': 'れ', 'ro': 'ろ',
      'wa': 'わ', 'wo': 'を', 'nn': 'ん',

      // Single vowels and n
      'a': 'あ', 'i': 'い', 'u': 'う', 'e': 'え', 'o': 'お',
      'n': 'ん',
    };

    String result = romaji.toLowerCase();

    // Sort by length descending to match longer patterns first
    final sortedKeys =
        map.keys.toList()..sort((a, b) => b.length.compareTo(a.length));

    for (var key in sortedKeys) {
      result = result.replaceAll(key, map[key]!);
    }

    return result;
  }

  // Close databases
  static Future<void> close() async {
    await _wordDb?.close();
    await _kanjiDb?.close();
  }
}

Future<dynamic> onSearch(String query) async {
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('🔍 Searching for: "$query"');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  final result = await JishoDB.search(query);
  final type = result['type'];
  final data = result['result'];

  if (type == 'kanji' && data is List && data.isNotEmpty) {
    final kanji = data.first;
    print('📝 KANJI: ${kanji['character']}');
    print('   Strokes: ${kanji['stroke_count']}');
    print('   On-yomi: ${kanji['on_yomi']?.join(', ')}');
    print('   Kun-yomi: ${kanji['kun_yomi']?.join(', ')}');
    print('   Meanings: ${kanji['meanings']?.join(', ')}');
  } else if (type == 'word' && data is List) {
    print('📚 Found ${data.length} word(s):\n');

    for (var i = 0; i < data.length && i < 5; i++) {
      final entry = data[i];
      print('${i + 1}. ${_formatEntry(entry)}');
      print('');
    }

    if (data.length > 5) {
      print('   ... and ${data.length - 5} more results');
    }
  } else {
    print('❌ No results found');
  }
  print('');
  return result;
}

String _formatEntry(Map<String, dynamic> entry) {
  final kanji = entry['kanji'] as List?;
  final reading = entry['reading'] as List?;
  final senses = entry['senses'] as List?;

  StringBuffer sb = StringBuffer();

  // Display kanji/reading
  if (kanji != null && kanji.isNotEmpty) {
    sb.write('${kanji.first}');
    if (reading != null && reading.isNotEmpty) {
      sb.write(' 【${reading.first}】');
    }
  } else if (reading != null && reading.isNotEmpty) {
    sb.write('${reading.first}');
  }

  // Display senses
  if (senses != null && senses.isNotEmpty) {
    for (var i = 0; i < senses.length && i < 3; i++) {
      final sense = senses[i];
      final pos = sense['pos'] as List?;
      final glosses = sense['glosses'] as List?;

      sb.write('\n   ');
      if (pos != null && pos.isNotEmpty) {
        sb.write('(${pos.join(', ')}) ');
      }
      if (glosses != null && glosses.isNotEmpty) {
        sb.write(glosses.join('; '));
      }
    }
  }

  return sb.toString();
}
