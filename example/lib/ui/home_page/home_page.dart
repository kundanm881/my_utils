// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:kd_utils/kd_utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("HomePage"),
      ),
      body: Center(
        child: Container(
          height: 300,
          width: 100,
          color: Colors.grey.shade300,
          child: CustomPaint(
            painter: DotLinePainter(
              dotheight: 4,
              space: 16,
              strokeWdith: 5,
              strokeCap: StrokeCap.round,
              axis: Axis.vertical,
            ),
          ),
        ),
      ),
    );
  }
}
