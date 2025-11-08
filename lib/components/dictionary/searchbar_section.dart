// File: lib/components/dictionary/searchbar_section.dart
import 'package:flutter/material.dart';

class SearchBarSection extends StatefulWidget {
  final Function(String) onSearch;
  final String selectedTab;
  final Function(String) onTabChanged;
  final List<Map<String, dynamic>> recognitionResults;
  final Function(String) onKanjiTap;

  const SearchBarSection({
    super.key,
    required this.onSearch,
    required this.selectedTab,
    required this.onTabChanged,
    required this.recognitionResults,
    required this.onKanjiTap,
  });

  @override
  State<SearchBarSection> createState() => _SearchBarSectionState();
}

class _SearchBarSectionState extends State<SearchBarSection> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar at Top
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: _buildSearchField(),
        ),

        // Tab Selector Below Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: _buildTabSelector(),
        ),

        // Recognition Results Carousel (shows when drawing tab has results)
        if (widget.selectedTab == 'draw' &&
            widget.recognitionResults.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: _buildRecognitionCarousel(),
          ),
      ],
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
            itemCount: widget.recognitionResults.length,
            itemBuilder: (context, index) {
              final result = widget.recognitionResults[index];
              final confidence = (result['confidence'] * 100).toStringAsFixed(
                1,
              );

              return GestureDetector(
                onTap: () => widget.onKanjiTap(result['kanji']),
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
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              icon: Icons.search,
              label: 'Үр дүн',
              value: 'search',
            ),
          ),
          Expanded(
            child: _buildTabButton(
              icon: Icons.draw,
              label: 'Зурах',
              value: 'draw',
            ),
          ),
          Expanded(
            child: _buildTabButton(
              icon: Icons.camera_alt,
              label: 'OCR',
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
    final isSelected = widget.selectedTab == value;
    return GestureDetector(
      onTap: () => widget.onTabChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color:
                  isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey[600],
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color:
                    isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
