// File: lib/components/dictionary/result_list.dart
import 'package:flutter/material.dart';

class DictionaryResultsList extends StatelessWidget {
  final List<Map<String, dynamic>> results;
  final String resultType;

  const DictionaryResultsList({
    super.key,
    required this.results,
    required this.resultType,
  });

  @override
  Widget build(BuildContext context) {
    if (resultType == 'kanji' && results.isNotEmpty) {
      return _buildKanjiResult(context, results.first);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        return _buildWordCard(context, results[index]);
      },
    );
  }

  Widget _buildKanjiResult(BuildContext context, Map<String, dynamic> kanji) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  kanji['character'] ?? '',
                  style: const TextStyle(
                    fontSize: 120,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildKanjiSection(
                'Зүрхэн тоо',
                [kanji['stroke_count']?.toString() ?? 'N/A'],
                Icons.brush,
              ),
              const Divider(height: 32),
              _buildKanjiSection(
                'Он уншилт',
                List<String>.from(kanji['on_yomi'] ?? []),
                Icons.volume_up,
              ),
              const Divider(height: 32),
              _buildKanjiSection(
                'Кун уншилт',
                List<String>.from(kanji['kun_yomi'] ?? []),
                Icons.speaker_notes,
              ),
              const Divider(height: 32),
              _buildKanjiSection(
                'Утга',
                List<String>.from(kanji['meanings'] ?? []),
                Icons.translate,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKanjiSection(String title, List<String> items, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.blue[700]),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (items.isEmpty)
          Text(
            'Мэдээлэл байхгүй',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Text(
                  item,
                  style: const TextStyle(fontSize: 14),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildWordCard(BuildContext context, Map<String, dynamic> entry) {
    final kanji = List<String>.from(entry['kanji'] ?? []);
    final reading = List<String>.from(entry['reading'] ?? []);
    final senses = List<Map<String, dynamic>>.from(entry['senses'] ?? []);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Word header
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                if (kanji.isNotEmpty)
                  Text(
                    kanji.first,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (kanji.isNotEmpty && reading.isNotEmpty)
                  const SizedBox(width: 12),
                if (reading.isNotEmpty)
                  Text(
                    '【${reading.first}】',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[700],
                    ),
                  ),
              ],
            ),
            
            // Show additional forms if available
            if (kanji.length > 1 || reading.length > 1)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (kanji.length > 1)
                      ...kanji.skip(1).map((k) => Chip(
                            label: Text(k, style: const TextStyle(fontSize: 12)),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: EdgeInsets.zero,
                          )),
                    if (reading.length > 1)
                      ...reading.skip(1).map((r) => Chip(
                            label: Text(r, style: const TextStyle(fontSize: 12)),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: EdgeInsets.zero,
                          )),
                  ],
                ),
              ),

            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),

            // Senses/Meanings
            ...senses.asMap().entries.map((entry) {
              final index = entry.key;
              final sense = entry.value;
              final pos = List<String>.from(sense['pos'] ?? []);
              final glosses = List<String>.from(sense['glosses'] ?? []);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${index + 1}.',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (pos.isNotEmpty)
                            Text(
                              pos.join(', '),
                              style: TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey[600],
                              ),
                            ),
                          if (pos.isNotEmpty) const SizedBox(height: 4),
                          Text(
                            glosses.join('; '),
                            style: const TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}