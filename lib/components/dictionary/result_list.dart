// File: lib/components/dictionary/dictionary_results_list.dart
import 'package:flutter/material.dart';
import 'package:ivo/components/dictionary/empty_state.dart';
import 'package:ivo/data/models/dictionary_entry.dart';
import 'package:ivo/components/dictionary/result_card.dart';


class DictionaryResultsList extends StatelessWidget {
  final List<DictionaryEntry> results;

  const DictionaryResultsList({
    super.key,
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const EmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DictionaryResultCard(entry: results[index]),
        );
      },
    );
  }
}
