import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class MyKanjiRecognizer {
  late Interpreter _interpreter;
  late List<String> labels;

  /// Load TFLite model and labels. Uses rootBundle for robust asset loading in Flutter.
  Future<void> loadModel() async {
    // 1. Load TFLite Model
    _interpreter = await Interpreter.fromAsset(
      'assets/ml_models/kanji_model.tflite',
    );

    // 2. Load Labels (Using rootBundle is the standard way to load Flutter assets)
    try {
      final labelString = await rootBundle.loadString(
        'assets/ml_models/labels.txt',
      );

      print('Raw label file length: ${labelString.length} characters');

      // Split by newline and filter out empty lines
      labels =
          labelString
              .split('\n')
              .map((line) => line.trim())
              .where((line) => line.isNotEmpty)
              .toList();

      print('Loaded ${labels.length} labels from labels.txt');

      if (labels.length < 6507) {
        print('WARNING: Expected 6507 labels but only found ${labels.length}');
        print('First few labels: ${labels.take(5).join(", ")}');
        print(
          'Make sure your labels.txt file contains all 6507 kanji characters',
        );
      } else {
        print('✓ Labels loaded successfully');
        print('First few labels: ${labels.take(5).join(", ")}');
      }
    } catch (e) {
      print('ERROR loading labels.txt: $e');
      labels = [];
    }
  }

  /// Convert grayscale image to normalized Float32List with correct shape [1, 64, 64, 1]
  List<List<List<List<double>>>> imageToModelInput(img.Image image) {
    final inputSize = image.width;

    // Create 4D array: [batch_size, height, width, channels]
    List<List<List<List<double>>>> input = List.generate(
      1, // batch_size
      (_) => List.generate(
        inputSize, // height
        (y) => List.generate(
          inputSize, // width
          (x) {
            // Get the Color object from the pixel
            final color = image.getPixel(x, y);
            final gray = color.r.toInt();

            // Invert: BLACK ink (0) on WHITE background (255)
            // becomes WHITE ink (1.0) on BLACK background (0.0)
            final invertedGray = 255 - gray;

            // Normalize to [0,1] and return as single-element list (channels dimension)
            return [(invertedGray / 255.0)];
          },
        ),
      ),
    );

    return input;
  }

  /// Predict the Kanji character from a grayscale image
  Map<String, dynamic> predict(img.Image image) {
    // Prepare input in the correct shape [1, 64, 64, 1]
    final input = imageToModelInput(image);

    // Get output tensor shape to determine number of classes
    final outputTensor = _interpreter.getOutputTensor(0);
    final outputShape = outputTensor.shape; // Should be [1, 6507]
    final numClasses = outputShape[1];

    print('Model expects ${numClasses} output classes');

    // Prepare output buffer: 2D array [1, num_classes]
    final outputBuffer = List.generate(
      1,
      (_) => List<double>.filled(numClasses, 0.0),
    );

    // Run inference
    _interpreter.run(input, outputBuffer);

    // Find the index of the max probability
    final probabilities = outputBuffer[0];
    double maxVal = probabilities[0];
    int predIndex = 0;
    for (int i = 1; i < probabilities.length; i++) {
      if (probabilities[i] > maxVal) {
        maxVal = probabilities[i];
        predIndex = i;
      }
    }

    // Get top 5 predictions for debugging
    List<MapEntry<int, double>> topPredictions = [];
    for (int i = 0; i < probabilities.length; i++) {
      topPredictions.add(MapEntry(i, probabilities[i]));
    }
    topPredictions.sort((a, b) => b.value.compareTo(a.value));

    print('Top 5 predictions:');
    List<Map<String, dynamic>> top5 = [];
    for (int i = 0; i < 5 && i < topPredictions.length; i++) {
      final idx = topPredictions[i].key;
      final conf = topPredictions[i].value;
      final label = idx < labels.length ? labels[idx] : 'Unknown';
      print(
        '  ${i + 1}. Index: $idx, Kanji: $label - ${(conf * 100).toStringAsFixed(2)}%',
      );
      top5.add({'index': idx, 'kanji': label, 'confidence': conf});
    }

    // Get the predicted kanji
    final predictedKanji =
        predIndex < labels.length ? labels[predIndex] : 'Unknown';

    print(
      'Final prediction: Index: $predIndex, Kanji: $predictedKanji, Confidence: ${(maxVal * 100).toStringAsFixed(2)}%',
    );

    // Return comprehensive result
    return {
      'index': predIndex,
      'kanji': predictedKanji,
      'confidence': maxVal,
      'top5': top5,
    };
  }

  void close() {
    _interpreter.close();
  }
}

/// Convert Flutter drawing points to a grayscale image (White background, Black ink)
Future<img.Image> convertDrawingToGrayscaleImage(
  List<Offset?> points,
  int size,
) async {
  // Find bounding box of the drawing
  double minX = double.infinity;
  double maxX = double.negativeInfinity;
  double minY = double.infinity;
  double maxY = double.negativeInfinity;

  for (final point in points) {
    if (point != null) {
      minX = point.dx < minX ? point.dx : minX;
      maxX = point.dx > maxX ? point.dx : maxX;
      minY = point.dy < minY ? point.dy : minY;
      maxY = point.dy > maxY ? point.dy : maxY;
    }
  }

  // Calculate scale to fit drawing into the target size with some padding
  final padding = size * 0.1; // 10% padding
  final availableSize = size - (2 * padding);
  final drawingWidth = maxX - minX;
  final drawingHeight = maxY - minY;
  final scale = (availableSize /
          (drawingWidth > drawingHeight ? drawingWidth : drawingHeight))
      .clamp(0.0, 10.0);

  // Calculate offset to center the drawing
  final offsetX = (size - (drawingWidth * scale)) / 2 - (minX * scale);
  final offsetY = (size - (drawingHeight * scale)) / 2 - (minY * scale);

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  final paint =
      Paint()
        ..color = Colors.black
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 8.0; // Thicker strokes for better recognition

  // White background
  canvas.drawRect(
    Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
    Paint()..color = Colors.white,
  );

  // Draw strokes with scaling and centering
  for (int i = 1; i < points.length; i++) {
    final p1 = points[i - 1];
    final p2 = points[i];
    if (p1 != null && p2 != null) {
      final scaledP1 = Offset(p1.dx * scale + offsetX, p1.dy * scale + offsetY);
      final scaledP2 = Offset(p2.dx * scale + offsetX, p2.dy * scale + offsetY);
      canvas.drawLine(scaledP1, scaledP2, paint);
    }
  }

  final picture = recorder.endRecording();
  final imgUi = await picture.toImage(size, size);
  final byteData = await imgUi.toByteData(format: ui.ImageByteFormat.rawRgba);
  final buffer = byteData!.buffer.asUint8List();

  // Create grayscale image using the image package
  final image = img.Image(width: size, height: size, numChannels: 4);

  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      final idx = (y * size + x) * 4;
      final r = buffer[idx];
      final g = buffer[idx + 1];
      final b = buffer[idx + 2];

      // Standard grayscale conversion
      final gray = ((0.299 * r) + (0.587 * g) + (0.114 * b)).toInt();

      // Set pixel in the image package
      image.setPixel(x, y, img.ColorRgba8(gray, gray, gray, 255));
    }
  }

  return image;
}
