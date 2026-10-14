import 'package:flutter/material.dart';

class DotLinePainter extends CustomPainter {
  DotLinePainter({
    this.paintColor = Colors.black,
    this.strokeWidth = 1,
    this.space = 4,
    this.dotHeight = 4,
    this.strokeCap = StrokeCap.butt,
    this.axis = Axis.vertical,
  });

  final Color paintColor;
  final double strokeWidth;
  final int space;
  final int dotHeight;
  final StrokeCap strokeCap;
  final Axis axis;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = paintColor
      ..strokeWidth = strokeWidth
      ..strokeCap = strokeCap;

    _drawDotLine(axis: axis, canvas: canvas, paint: paint, size: size);
  }

  void _drawDotLine({
    required Axis axis,
    required Canvas canvas,
    required Paint paint,
    required Size size,
  }) {
    final double boxHeight = size.height;
    final double boxWidth = size.width;
    final step = dotHeight + space;
    if (step <= 0) return;

    if (axis == Axis.horizontal) {
      for (double startPoint = 0; startPoint <= boxWidth; startPoint += step) {
        final double endPoint = (startPoint + dotHeight).clamp(0.0, boxWidth);
        canvas.drawLine(
          Offset(startPoint, 0),
          Offset(endPoint, 0),
          paint,
        );
      }
    } else {
      for (double startPoint = 0; startPoint <= boxHeight; startPoint += step) {
        final double endPoint = (startPoint + dotHeight).clamp(0.0, boxHeight);
        canvas.drawLine(
          Offset(0, startPoint),
          Offset(0, endPoint),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant DotLinePainter oldDelegate) {
    return oldDelegate.paintColor != paintColor ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.space != space ||
        oldDelegate.dotHeight != dotHeight ||
        oldDelegate.strokeCap != strokeCap ||
        oldDelegate.axis != axis;
  }
}
