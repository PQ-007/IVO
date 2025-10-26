// File: lib/components/dictionary/MyDrawingPad.dart
import 'package:flutter/material.dart';

class DrawingPad extends StatefulWidget {
  final VoidCallback onSearch;

  const DrawingPad({super.key, required this.onSearch});

  @override
  State<DrawingPad> createState() => _DrawingPadState();
}

class _DrawingPadState extends State<DrawingPad> {
  List<Offset?> _drawingPoints = [];
  bool _showGrid = true;
  int _selectedKanjiIndex = 0;

  final List<Map<String, String>> _sampleKanji = [
    {'kanji': '日', 'meaning': 'sun, day'},
    {'kanji': '月', 'meaning': 'moon, month'},
    {'kanji': '火', 'meaning': 'fire'},
    {'kanji': '水', 'meaning': 'water'},
    {'kanji': '木', 'meaning': 'tree, wood'},
    {'kanji': '金', 'meaning': 'gold, metal'},
    {'kanji': '土', 'meaning': 'earth, soil'},
    {'kanji': '人', 'meaning': 'person'},
    {'kanji': '山', 'meaning': 'mountain'},
    {'kanji': '川', 'meaning': 'river'},
  ];

  void _clearDrawing() {
    setState(() {
      _drawingPoints = [];
    });
  }

  void _toggleGrid() {
    setState(() {
      _showGrid = !_showGrid;
    });
  }

  int _countStrokes() {
    int count = 0;
    for (int i = 0; i < _drawingPoints.length; i++) {
      if (i == 0 && _drawingPoints[i] != null) {
        count++;
      } else if (i > 0 &&
          _drawingPoints[i] != null &&
          _drawingPoints[i - 1] == null) {
        count++;
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        _buildKanjiCarousel(),
        const SizedBox(height: 16),
        AspectRatio(
          aspectRatio: 1.0,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                children: [
                  if (_showGrid)
                    CustomPaint(
                      painter: _QuadraticGridPainter(),
                      size: Size.infinite,
                    ),

                  // Drawing area
                  Listener(
                    onPointerDown: (event) {
                      setState(() {
                        _drawingPoints = List.from(_drawingPoints)
                          ..add(event.localPosition);
                      });
                    },
                    onPointerMove: (event) {
                      setState(() {
                        _drawingPoints = List.from(_drawingPoints)
                          ..add(event.localPosition);
                      });
                    },
                    onPointerUp: (event) {
                      setState(() {
                        _drawingPoints = List.from(_drawingPoints)..add(null);
                      });
                    },
                    child: CustomPaint(
                      painter: _DrawingPainter(_drawingPoints, isDark: isDark),
                      size: Size.infinite,
                    ),
                  ),

                  if (_drawingPoints.isEmpty)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.draw_outlined, size: 56),
                          const SizedBox(height: 12),
                          Text(
                            'Draw a kanji character',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Use the grid as a guide',
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),

                  Positioned(top: 8, left: 8, child: _buildGridToggle()),

                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Row(
                      children: [
                        _buildActionButton(
                          icon: Icons.refresh,
                          label: 'Clear',
                          onPressed: _clearDrawing,
                          isPrimary: false,
                        ),
                        const SizedBox(width: 8),
                        _buildActionButton(
                          icon: Icons.search,
                          label: 'Search',
                          onPressed: widget.onSearch,
                          isPrimary: true,
                        ),
                      ],
                    ),
                  ),

                  if (_drawingPoints.isNotEmpty)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.gesture, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              '${_countStrokes()} strokes',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              Icon(Icons.lightbulb_outline, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tip: Draw strokes in the correct order for better recognition',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKanjiCarousel() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _sampleKanji.length,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedKanjiIndex;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedKanjiIndex = index;
              });
            },
            child: Container(
              width: 100,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(width: isSelected ? 2 : 1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _sampleKanji[index]['kanji']!,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      _sampleKanji[index]['meaning']!,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildGridToggle() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: _toggleGrid,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(_showGrid ? Icons.grid_4x4 : Icons.grid_off, size: 20),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _QuadraticGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint =
        Paint()
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke;

    final plusPaint =
        Paint()
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), borderPaint);

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    canvas.drawLine(
      Offset(centerX, 0),
      Offset(centerX, size.height),
      plusPaint,
    );
    canvas.drawLine(Offset(0, centerY), Offset(size.width, centerY), plusPaint);
  }

  @override
  bool shouldRepaint(_QuadraticGridPainter oldDelegate) => false;
}

class _DrawingPainter extends CustomPainter {
  final List<Offset?> points;
  final bool isDark;

  _DrawingPainter(this.points, {required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint =
        Paint()
          ..color = isDark ? Colors.white : Colors.black
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 5.0
          ..style = PaintingStyle.stroke;

    for (int i = 1; i < points.length; i++) {
      final current = points[i];
      final previous = points[i - 1];
      if (current != null && previous != null) {
        canvas.drawLine(previous, current, linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(_DrawingPainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.isDark != isDark;
}
