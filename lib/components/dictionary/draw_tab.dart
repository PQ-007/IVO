// File: lib/components/dictionary/draw_tab.dart
import 'package:flutter/material.dart';
import 'package:ivo/components/dictionary/drawing_pad.dart';
import 'package:ivo/services/db_helper.dart';

class DrawTab extends StatefulWidget {
  const DrawTab({super.key});

  @override
  State<DrawTab> createState() => _DrawTabState();
}

class _DrawTabState extends State<DrawTab> {
  List<Map<String, dynamic>> _recognitionResults = [];
  Map<String, dynamic>? _selectedKanjiDetails;
  bool _isLoadingDetails = false;

  void _handleRecognitionResult(Map<String, dynamic> result) {
    setState(() {
      _recognitionResults = result['top5'] as List<Map<String, dynamic>>;
      _selectedKanjiDetails = null; // Reset selected kanji
    });
  }

  Future<void> _onKanjiTap(String kanji) async {
    setState(() {
      _isLoadingDetails = true;
    });

    try {
      final result = await JishoDB.search(kanji);
      if (result['type'] == 'kanji' && result['result'] is List && (result['result'] as List).isNotEmpty) {
        setState(() {
          _selectedKanjiDetails = result['result'][0] as Map<String, dynamic>;
          _isLoadingDetails = false;
        });
      } else {
        setState(() {
          _selectedKanjiDetails = null;
          _isLoadingDetails = false;
        });
      }
    } catch (e) {
      print('Error loading kanji details: $e');
      setState(() {
        _isLoadingDetails = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Drawing Pad
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: DrawingPad(onRecognitionComplete: _handleRecognitionResult),
          ),

          // Recognition Results
          if (_recognitionResults.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Танилтын үр дүнгүүд:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildRecognitionCarousel(),
                ],
              ),
            ),
          ],

          // Selected Kanji Details
          if (_isLoadingDetails)
            const Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            )
          else if (_selectedKanjiDetails != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildKanjiDetails(_selectedKanjiDetails!),
            ),

          // Empty State
          if (_recognitionResults.isEmpty && _selectedKanjiDetails == null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 60),
              child: Column(
                children: [
                  Icon(Icons.draw, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Дээрх хүрээнд ханз зур',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecognitionCarousel() {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _recognitionResults.length,
        itemBuilder: (context, index) {
          final result = _recognitionResults[index];
          final confidence = (result['confidence'] * 100).toStringAsFixed(1);
          final isSelected = _selectedKanjiDetails != null &&
              _selectedKanjiDetails!['character'] == result['kanji'];

          return GestureDetector(
            onTap: () => _onKanjiTap(result['kanji']),
            child: Container(
              width: 95,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  width: isSelected ? 2.5 : (index == 0 ? 2 : 1),
                  color: isSelected
                      ? Colors.green
                      : (index == 0
                          ? Theme.of(context).primaryColor
                          : Colors.grey[300]!),
                ),
                color: isSelected
                    ? Colors.green.withOpacity(0.05)
                    : (index == 0
                        ? Theme.of(context).primaryColor.withOpacity(0.05)
                        : Colors.white),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    result['kanji'],
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$confidence%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildKanjiDetails(Map<String, dynamic> kanji) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Large Kanji Display
            Center(
              child: Text(
                kanji['character'] ?? '',
                style: const TextStyle(
                  fontSize: 100,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 32, thickness: 1.5),

            // Details
            _buildDetailRow(
              'Штрих тоо:',
              '${kanji['stroke_count']} штрих',
              Icons.create,
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              'Он-дууд:',
              (kanji['on_yomi'] as List?)?.join(', ') ?? '-',
              Icons.volume_up,
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              'Кун-дууд:',
              (kanji['kun_yomi'] as List?)?.join(', ') ?? '-',
              Icons.record_voice_over,
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              'Утга:',
              (kanji['meanings'] as List?)?.join(', ') ?? '-',
              Icons.translate,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.blue[700]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
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
          ),
        ),
      ],
    );
  }
}