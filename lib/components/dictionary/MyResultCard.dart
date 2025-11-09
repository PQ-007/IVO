// File: lib/components/dictionary/dictionary_result_card.dart
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:ivo/components/dictionary/MyDetailDialog.dart';
import 'package:ivo/data/models/dictionary_entry.dart';

class DictionaryResultCard extends StatelessWidget {
  final DictionaryEntry entry;

  const DictionaryResultCard({
    super.key,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    return FCard(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _showDetailDialog(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 12),
              Text(
                entry.meaning,
                style: context.theme.typography.base,
              ),
              const SizedBox(height: 12),
              _buildExample(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.word,
                style: context.theme.typography.xl2.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                entry.reading,
                style: context.theme.typography.base.copyWith(
                  
                ),
              ),
            ],
          ),
        ),
        FBadge(
          style: FBadgeStyle.primary(),
          child: Text(entry.type),
        ),
      ],
    );
  }

  Widget _buildExample(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(
            Icons.format_quote,
            size: 16,
            
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              entry.examples.first,
              style: context.theme.typography.sm.copyWith(
                
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => DictionaryDetailDialog(entry: entry),
    );
  }
}

