// File: lib/pages/dictionary_page.dart
import 'package:flutter/material.dart';
import 'package:ivo/components/app_bar.dart';
import 'package:ivo/components/buttons/dark_mode_button.dart';
import 'package:ivo/components/buttons/settings_nav_button.dart';
import 'package:ivo/components/dictionary/ocr_scanner.dart';
import 'package:ivo/components/dictionary/searchbar_section.dart';
import 'package:ivo/components/dictionary/result_list.dart';
import 'package:ivo/components/dictionary/drawing_pad.dart';
import 'package:ivo/services/db_helper.dart';

class DictionaryPage extends StatefulWidget {
  const DictionaryPage({super.key});

  @override
  State<DictionaryPage> createState() => _DictionaryPageState();
}

class _DictionaryPageState extends State<DictionaryPage> {
  String _selectedTab = 'search';
  String _searchQuery = '';
  List<Map<String, dynamic>> _searchResults = [];
  String _resultType = 'empty';
  bool _isLoading = false;
  List<Map<String, dynamic>> _recognitionResults = [];

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    try {
      await JishoDB.init();
      print('Database initialized successfully');
    } catch (e) {
      print('Error initializing database: $e');
    }
  }

  void _onTabChanged(String tab) {
    setState(() {
      _selectedTab = tab;
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _searchQuery = query;
      _isLoading = true;
      _selectedTab = "search";
    });

    try {
      if (query.trim().isEmpty) {
        setState(() {
          _searchResults = [];
          _resultType = 'empty';
          _isLoading = false;
        });
        return;
      }

      final result = await JishoDB.search(query);
      setState(() {
        _resultType = result['type'];
        _searchResults = List<Map<String, dynamic>>.from(
          result['result'] ?? [],
        );
        _isLoading = false;
      });
    } catch (e) {
      print('Search error: $e');
      setState(() {
        _searchResults = [];
        _resultType = 'error';
        _isLoading = false;
      });
    }
  }

  void _handleRecognitionResult(Map<String, dynamic> result) {
    setState(() {
      _recognitionResults = result['top5'] as List<Map<String, dynamic>>;
    });
  }

  void _onKanjiTap(String kanji) {
    
  }

  void _onOcrResult(String text) {
    if (text.isNotEmpty) {
      _performSearch(text);
      setState(() {
        _selectedTab = 'search';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: MyAppBar(
        titleText: "Толь бичиг",
        button1: DarkModeButton(),
        button2: SettingsNavButton(),
      ),
      body: Column(
        children: [
          // Search Bar at Top
          SearchBarSection(
            onSearch: _performSearch,
            selectedTab: _selectedTab,
            onTabChanged: _onTabChanged,
            recognitionResults: _recognitionResults,
            onKanjiTap: _onKanjiTap,
          ),

          // Content Area
          Expanded(child: _buildTabContent()),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 'search':
        if (_isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_searchResults.isEmpty && _searchQuery.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Үр дүн олдсонгүй',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }
        if (_searchResults.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.book_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Хайлт хийнэ үү',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }
        return DictionaryResultsList(
          results: _searchResults,
          resultType: _resultType,
        );

      case 'draw':
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: DrawingPad(onRecognitionComplete: _handleRecognitionResult),
        );

      case 'ocr':
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: OcrScanner(onTextRecognized: _onOcrResult),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
