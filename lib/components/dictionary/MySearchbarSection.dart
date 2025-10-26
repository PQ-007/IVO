// File: lib/components/dictionary/MySearchbarSection.dart
import 'package:flutter/material.dart';
import 'package:ivo/components/dictionary/MyDrawingPad.dart';

class SearchBarSection extends StatefulWidget {
  final Function(String) onSearch;
  final VoidCallback onDrawingSearch;

  const SearchBarSection({
    super.key,
    required this.onSearch,
    required this.onDrawingSearch,
  });

  @override
  State<SearchBarSection> createState() => _SearchBarSectionState();
}

class _SearchBarSectionState extends State<SearchBarSection> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedTab = 'search';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

          // Content Area (Drawing Pad or Empty Space)
          if (_selectedTab == 'draw')
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: DrawingPad(onSearch: widget.onDrawingSearch),
            ),
        ],
      ),
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
          hintText: 'Search word, reading, or meaning...',
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
              label: 'Text Search',
              value: 'search',
            ),
          ),
          Expanded(
            child: _buildTabButton(
              icon: Icons.draw,
              label: 'Draw Search',
              value: 'draw',
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
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
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
