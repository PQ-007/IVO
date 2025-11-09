// File: lib/components/dictionary/search_bar_widget.dart

import 'package:flutter/material.dart';
import 'package:forui/assets.dart';

// --- Change to StatefulWidget ---
class DictionarySearchBar extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onSearch;
  final VoidCallback onClear;
  final VoidCallback onOpenOcr;

  const DictionarySearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSearch,
    required this.onClear,
    required this.onOpenOcr,
  });

  @override
  State<DictionarySearchBar> createState() => _DictionarySearchBarState();
}

class _DictionarySearchBarState extends State<DictionarySearchBar> {
  // Flag to track if the text field is empty
  bool _isTextEmpty = true;

  @override
  void initState() {
    super.initState();
    // Initialize the flag with the current controller state
    _isTextEmpty = widget.controller.text.isEmpty;

    // 🎧 Add a listener to the controller
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    // 🧹 Remove the listener when the widget is disposed
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    // 🔍 Check if the text status has actually changed
    final currentIsTextEmpty = widget.controller.text.isEmpty;
    if (_isTextEmpty != currentIsTextEmpty) {
      // 🔄 If it changed, update the state to trigger a rebuild
      setState(() {
        _isTextEmpty = currentIsTextEmpty;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access properties using widget.
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(FIcons.origami, size: 22),
                  ),
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      focusNode: widget.focusNode,
                      onSubmitted: widget.onSearch,
                      decoration: const InputDecoration(
                        hintText: 'Үг, утга, дуудлага...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  // Use the internal state for showing the clear button
                  if (!_isTextEmpty) // or widget.controller.text.isNotEmpty
                    IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: widget.onClear,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(12),
            ),
            // Use the internal state for showing the correct button
            child:
                _isTextEmpty
                    ? IconButton(
                      icon: const Icon(
                        FIcons.scanSearch,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: widget.onOpenOcr,
                      tooltip: 'Зураг таних',
                    )
                    : IconButton(
                      // Pass the current text to onSearch
                      onPressed: () => widget.onSearch(widget.controller.text),
                      icon: const Icon(
                        Icons.search,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
