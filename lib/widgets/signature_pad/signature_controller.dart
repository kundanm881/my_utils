import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Controller for managing signature strokes, painting, and image exports.
class SignatureController extends ChangeNotifier {
  Color penColor;
  double strokeWidth;
  Color? exportBackgroundColor;

  final List<List<Offset>> _strokes = [];
  List<Offset>? _currentStroke;

  SignatureController({
    this.penColor = const Color(0xFF0F172A),
    double? strokeWidth,
    double? penStrokeWidth,
    this.exportBackgroundColor,
  }) : strokeWidth = penStrokeWidth ?? strokeWidth ?? 3.0;

  /// Read-only copy of completed strokes
  List<List<Offset>> get strokes => List.unmodifiable(_strokes);

  /// Currently active in-progress stroke
  List<Offset>? get currentStroke => _currentStroke;

  /// Whether the signature pad has no drawn strokes
  bool get isEmpty => _strokes.isEmpty && (_currentStroke == null || _currentStroke!.isEmpty);

  /// Whether the signature pad has drawn strokes
  bool get isNotEmpty => !isEmpty;

  /// Count of completed strokes
  int get strokeCount => _strokes.length;

  /// Begin a new stroke at the given coordinate
  void startStroke(Offset point) {
    _currentStroke = [point];
    _strokes.add(_currentStroke!);
    notifyListeners();
  }

  /// Add a point to the current active stroke
  void addPoint(Offset point) {
    if (_currentStroke == null) {
      startStroke(point);
      return;
    }
    _currentStroke!.add(point);
    notifyListeners();
  }

  /// Complete the current active stroke
  void endStroke() {
    _currentStroke = null;
    notifyListeners();
  }

  /// Remove the most recent stroke
  void undo() {
    if (_strokes.isNotEmpty) {
      _strokes.removeLast();
      _currentStroke = null;
      notifyListeners();
    }
  }

  /// Clear all strokes
  void clear() {
    _strokes.clear();
    _currentStroke = null;
    notifyListeners();
  }

  /// Render the drawn signature to a [ui.Image]
  Future<ui.Image?> toImage({
    double width = 500,
    double height = 220,
    Color? background,
  }) async {
    if (isEmpty) return null;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, width, height));

    final effectiveBg = background ?? exportBackgroundColor;
    if (effectiveBg != null) {
      final bgPaint = Paint()..color = effectiveBg;
      canvas.drawRect(Rect.fromLTWH(0, 0, width, height), bgPaint);
    }

    final paint = Paint()
      ..color = penColor
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    for (final stroke in _strokes) {
      if (stroke.isEmpty) continue;
      if (stroke.length == 1) {
        canvas.drawCircle(
          stroke.first,
          strokeWidth / 2,
          paint..style = PaintingStyle.fill,
        );
        paint.style = PaintingStyle.stroke;
      } else {
        final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
        for (int i = 1; i < stroke.length; i++) {
          path.lineTo(stroke[i].dx, stroke[i].dy);
        }
        canvas.drawPath(path, paint);
      }
    }

    final picture = recorder.endRecording();
    return picture.toImage(width.toInt(), height.toInt());
  }

  /// Export the signature as raw PNG bytes [Uint8List]
  Future<Uint8List?> toPngBytes({
    double width = 500,
    double height = 220,
    Color? background,
  }) async {
    final image = await toImage(width: width, height: height, background: background);
    if (image == null) return null;
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  /// Export the signature as a Base64-encoded PNG string
  Future<String?> toBase64Png({
    double width = 500,
    double height = 220,
    Color? background,
  }) async {
    final bytes = await toPngBytes(width: width, height: height, background: background);
    if (bytes == null) return null;
    return base64Encode(bytes);
  }
}
