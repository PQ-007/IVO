// File: lib/components/dictionary/MySearchbarSection.dart
import 'package:flutter/material.dart';
import 'package:ivo/components/dictionary/MyDrawingPad.dart';

class SearchBarSection extends StatefulWidget {
  final Function(String) onSearch;

  const SearchBarSection({super.key, required this.onSearch});

  @override
  State<SearchBarSection> createState() => _SearchBarSectionState();
}

class _SearchBarSectionState extends State<SearchBarSection> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedTab = 'search';
  List<Map<String, dynamic>> _recognitionResults = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleRecognitionResult(Map<String, dynamic> result) {
    setState(() {
      _recognitionResults = result['top5'] as List<Map<String, dynamic>>;
    });
  }

  void _onKanjiTap(String kanji) {
    _searchController.text = _searchController.text + kanji;
    widget.onSearch(kanji);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar at Top
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: _buildSearchField(),
          ),

          // Tab Selector Below Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildTabSelector(),
          ),

          const SizedBox(height: 16),

          // Recognition Results Carousel (shows third type)
          if (_selectedTab == 'draw' && _recognitionResults.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildRecognitionCarousel(),
            ),

          // Spacing when no results
          if (_selectedTab == 'draw' && _recognitionResults.isEmpty)
            const SizedBox(height: 140),

          // Content Area (Drawing Pad or Empty Space)
          if (_selectedTab == 'draw')
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: DrawingPad(
                onRecognitionComplete: _handleRecognitionResult,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecognitionCarousel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Танилтын үр дүнгүүд:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _recognitionResults.length,
            itemBuilder: (context, index) {
              final result = _recognitionResults[index];
              final confidence = (result['confidence'] * 100).toStringAsFixed(
                1,
              );

              return GestureDetector(
                onTap: () => _onKanjiTap(result['kanji']),
                child: Container(
                  width: 90,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      width: index == 0 ? 2 : 1,
                      color:
                          index == 0
                              ? Theme.of(context).primaryColor
                              : Colors.grey[300]!,
                    ),
                    color:
                        index == 0
                            ? Theme.of(context).primaryColor.withOpacity(0.05)
                            : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        result['kanji'],
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$confidence%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {});
          widget.onSearch(value);
        },
        decoration: InputDecoration(
          hintText: 'Үг, утга, дуудлага...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                      widget.onSearch('');
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

  Widget _buildTabSelector() {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              icon: Icons.search,
              label: 'Текст хайлт',
              value: 'search',
            ),
          ),
          Expanded(
            child: _buildTabButton(
              icon: Icons.draw,
              label: 'Зурж хайлт',
              value: 'draw',
            ),
          ),
          Expanded(
            child: _buildTabButton(
              icon: Icons.camera_alt,
              label: 'OCR танилт',
              value: 'ocr',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final isSelected = _selectedTab == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
