// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:kd_utils/kd_utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

List<BorderStyle> newStyle = BorderStyle.values;

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("HomePage"),
      ),
      body: Column(
        children: [
          Text("${context.viewPadding} + ${context.screenSize}"),
          20.height,
          Text("$newStyle + ${context.screenWidth}"),
          // Text("${10.n} "),
          30.height,
          Center(
            child: CustomPaint(
                child: Container(
                  height: 100,
                  width: 100,
                  // color: Colors.grey.shade300,
                ),
                // foregroundPainter: DotBorder()
                painter: DotLinePainter(
                  dotheight: 4,
                  space: 16,
                  strokeWdith: 5,
                  strokeCap: StrokeCap.round,
                  axis: Axis.vertical,
                ),
                ),
          ),
        ],
      ),
    );
  }
}

// class DotBorder extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     // Paint dotPaint = Paint()
//     //   ..color = Colors.green
//     //   ..strokeWidth = 5;

//     // canvas.drawLine(
//     //   Offset.zero,
//     //   Offset(0, size.width),
//     //   dotPaint,
//     // );
  
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return false;
//   }
// }
