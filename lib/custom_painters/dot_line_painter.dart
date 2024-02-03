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

    _dowDotLine(axis: axis, canvas: canvas, paint: paint, size: size);
  }

  _dowDotLine({
    required Axis axis,
    required Canvas canvas,
    required Paint paint,
    required Size size,
  }) {
    final double boxHeight = size.height;
    final double boxWidth = size.width;

    if (axis == Axis.horizontal) {
      for (int startPoint = 0; startPoint <= boxWidth; startPoint += space) {
        double sp = startPoint.toDouble();
        double enp = (startPoint += dotHeight).toDouble();
        canvas.drawLine(
          Offset(sp, 0),
          Offset(enp, 0),
          paint,
        );
      }
    } else {
      for (int startPoint = 0; startPoint <= boxHeight; startPoint += space) {
        double sp = startPoint.toDouble();
        double enp = (startPoint += dotHeight).toDouble();
        canvas.drawLine(
          Offset(0, sp),
          Offset(0, enp),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
