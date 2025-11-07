// File: lib/components/dictionary/search_tab.dart
import 'package:flutter/material.dart';
import 'package:ivo/services/db_helper.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  String _searchType = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _searchType = '';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await JishoDB.search(query);
      setState(() {
        _searchType = result['type'] ?? '';
        _searchResults = List<Map<String, dynamic>>.from(result['result'] ?? []);
        _isLoading = false;
      });
    } catch (e) {
      print('Search error: $e');
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: _buildSearchField(),
        ),

        // Results Area
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _searchResults.isEmpty
                  ? _buildEmptyState()
                  : _buildResultsList(),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: _searchController,
        // onChanged: (value) => _performSearch(value),
        decoration: InputDecoration(
          hintText: 'Үг, утга, дуудлага хайх...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: IconButton(onPressed: () { _performSearch(_searchController.text); }, icon: Icon(Icons.search)),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _performSearch('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Хайлт хийхийн тулд дээр текст оруулна уу',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    if (_searchType == 'kanji') {
      return _buildKanjiResults();
    } else if (_searchType == 'word') {
      return _buildWordResults();
    }
    return _buildEmptyState();
  }

  Widget _buildKanjiResults() {
    if (_searchResults.isEmpty) return _buildNoResults();

    final kanji = _searchResults.first;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  kanji['character'] ?? '',
                  style: const TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 32),
              _buildKanjiDetail('Зурлагын тоо', '${kanji['stroke_count']} зурлага'),
              const SizedBox(height: 12),
              _buildKanjiDetail(
                'Он-дууд',
                (kanji['on_yomi'] as List?)?.join(', ') ?? '-',
              ),
              const SizedBox(height: 12),
              _buildKanjiDetail(
                'Кун-дууд',
                (kanji['kun_yomi'] as List?)?.join(', ') ?? '-',
              ),
              const SizedBox(height: 12),
              _buildKanjiDetail(
                'Утга',
                (kanji['meanings'] as List?)?.join(', ') ?? '-',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKanjiDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildWordResults() {
    if (_searchResults.isEmpty) return _buildNoResults();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final entry = _searchResults[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEntryHeader(entry),
                const SizedBox(height: 12),
                _buildEntrySenses(entry),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEntryHeader(Map<String, dynamic> entry) {
    final kanji = entry['kanji'] as List?;
    final reading = entry['reading'] as List?;

    return Row(
      children: [
        if (kanji != null && kanji.isNotEmpty)
          Text(
            kanji.first.toString(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        if (kanji != null && kanji.isNotEmpty && reading != null && reading.isNotEmpty)
          const SizedBox(width: 8),
        if (reading != null && reading.isNotEmpty)
          Text(
            '【${reading.first}】',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
      ],
    );
  }

  Widget _buildEntrySenses(Map<String, dynamic> entry) {
    final senses = entry['senses'] as List?;
    if (senses == null || senses.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        senses.length > 3 ? 3 : senses.length,
        (index) {
          final sense = senses[index] as Map<String, dynamic>;
          final pos = sense['pos'] as List?;
          final glosses = sense['glosses'] as List?;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${index + 1}. ',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (pos != null && pos.isNotEmpty)
                        Text(
                          '(${pos.join(', ')})',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      if (glosses != null && glosses.isNotEmpty)
                        Text(
                          glosses.join('; '),
                          style: const TextStyle(fontSize: 14),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Илэрц олдсонгүй',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}