// File: lib/components/dictionary/empty_state.dart
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: context.theme.typography.lg.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term',
            style: context.theme.typography.sm.copyWith(
              
            ),
          ),
        ],
      ),
    );
  }
}