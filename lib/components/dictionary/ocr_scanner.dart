// File: lib/components/dictionary/ocr_scanner.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrScanner extends StatefulWidget {
  final Function(String) onTextRecognized;

  const OcrScanner({super.key, required this.onTextRecognized});

  @override
  State<OcrScanner> createState() => _OcrScannerState();
}

class _OcrScannerState extends State<OcrScanner> {
  File? _image;
  String _recognizedText = '';
  bool _isProcessing = false;
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.japanese);

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      
      if (pickedFile == null) return;

      setState(() {
        _image = File(pickedFile.path);
        _isProcessing = true;
        _recognizedText = '';
      });

      await _processImage(File(pickedFile.path));
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Зураг сонгохот алдаа гарлаа: $e')),
        );
      }
    }
  }

  Future<void> _processImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      String text = recognizedText.text;
      
      setState(() {
        _recognizedText = text;
        _isProcessing = false;
      });

      if (text.isNotEmpty) {
        print('Recognized text: $text');
      }
    } catch (e) {
      print('Error processing image: $e');
      setState(() {
        _isProcessing = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Текст танихад алдаа гарлаа: $e')),
        );
      }
    }
  }

  void _searchSelectedText(String text) {
    if (text.trim().isNotEmpty) {
      widget.onTextRecognized(text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          
          // Image preview area
          if (_image != null)
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  _image!,
                  fit: BoxFit.contain,
                ),
              ),
            )
          else
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!, width: 2),
                color: Colors.grey[50],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Зураг сонгоно уу',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildActionButton(
                icon: Icons.camera_alt,
                label: 'Камер',
                onPressed: () => _pickImage(ImageSource.camera),
              ),
              const SizedBox(width: 16),
              _buildActionButton(
                icon: Icons.photo_library,
                label: 'Галерей',
                onPressed: () => _pickImage(ImageSource.gallery),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Processing indicator
          if (_isProcessing)
            const Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Текст танигдаж байна...'),
              ],
            ),

          // Recognized text display
          if (_recognizedText.isNotEmpty && !_isProcessing)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Танигдсан текст:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.blue[700],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          // Copy to clipboard functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Текст хуулагдлаа')),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    _recognizedText,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _searchSelectedText(_recognizedText),
                      icon: const Icon(Icons.search),
                      label: const Text('Энэ текстээр хайх'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Instructions
          if (_image == null)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(top: 24),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Япон хэл агуулсан зургийг сонгоорой. Текст автоматаар таниулна.',
                      style: TextStyle(fontSize: 13, color: Colors.blue[900]),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}