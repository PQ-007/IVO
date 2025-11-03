// File: lib/pages/dictionary_page.dart
import 'package:flutter/material.dart';
import 'package:ivo/components/MyAppbarr.dart';
import 'package:ivo/components/dictionary/result_list.dart';
import 'package:ivo/components/dictionary/searchbar_section.dart';
import 'package:ivo/data/dictionary_data.dart';
import 'package:ivo/data/models/dictionary_entry.dart';

class DictionaryPage extends StatefulWidget {
  const DictionaryPage({super.key});

  @override
  State<DictionaryPage> createState() => _DictionaryPageState();
}

class _DictionaryPageState extends State<DictionaryPage> {
  List<DictionaryEntry> _searchResults = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchResults = DictionaryData.entries;
  }

  void _performSearch(String query) {
    setState(() {
      _isLoading = true;
    });

    // Simulate search delay
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        if (query.isEmpty) {
          _searchResults = DictionaryData.entries;
        } else {
          _searchResults =
              DictionaryData.entries.where((entry) {
                return entry.word.toLowerCase().contains(query.toLowerCase()) ||
                    entry.reading.toLowerCase().contains(query.toLowerCase()) ||
                    entry.meaning.toLowerCase().contains(query.toLowerCase());
              }).toList();
        }
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: MyAppBar(titleText: "Толь бичиг"),
      body: Column(
        children: [
          SearchBarSection(onSearch: _performSearch),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : DictionaryResultsList(results: _searchResults),
          ),
        ],
      ),
    );
  }
}
