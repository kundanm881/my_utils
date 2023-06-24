import 'package:flutter/material.dart';

class DotLinePainter extends CustomPainter {
  DotLinePainter({
    this.paintColor = Colors.black,
    this.strokeWdith = 1,
    this.space = 4,
    this.dotheight = 4,
    this.strokeCap = StrokeCap.butt,
    this.axis = Axis.vertical,
  });

  final Color paintColor;
  final double strokeWdith;
  final int space;
  final int dotheight;
  final StrokeCap strokeCap;
  final Axis axis;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = paintColor
      ..strokeWidth = strokeWdith
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
    int startPoint = 0;

    if (axis == Axis.horizontal) {
      for (; startPoint <= boxWidth; startPoint += space) {
        double sp = startPoint.toDouble();
        double enp = (startPoint += dotheight).toDouble();
        canvas.drawLine(
          Offset(sp, 0),
          Offset(enp, 0),
          paint,
        );
      }
    } else {
      for (; startPoint <= boxHeight; startPoint += space) {
        double sp = startPoint.toDouble();
        double enp = (startPoint += dotheight).toDouble();
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
