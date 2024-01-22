// ignore_for_file: prefer_const_constructors

import 'package:example/ui/home_page/home_page_state.dart';
import 'package:flutter/material.dart';
import 'package:kd_utils/kd_utils.dart';

class HomePageView extends StatefulWidget {
  const HomePageView({super.key});

  @override
  State<HomePageView> createState() => _HomePageViewState();
}

List<BorderStyle> newStyle = BorderStyle.values;

class _HomePageViewState extends HomePageSate {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff191825),
      body: Stack(
        children: [
          Image.asset(
            "assets/img/bg.png",
            fit: BoxFit.contain,
            alignment: Alignment.topCenter,
            width: double.maxFinite,
            height: double.maxFinite,
          ),
          ListView(
            padding: EdgeInsets.symmetric(horizontal: 43),
            children: [
              CustomPaint(
                foregroundPainter: DotLinePainter(
                  dotheight: 4,
                  space: 16,
                  strokeWdith: 5,
                  strokeCap: StrokeCap.round,
                  axis: Axis.horizontal,
                ),
                child: Container(
                  height: 100,
                  width: 200,
                  color: Colors.green,
                ),
              ),
              143.height,
              TweenAnimationBuilder(
                tween: Tween(begin: 1.0, end: 0.0),
                duration: Duration(milliseconds: 600),
                curve: Curves.easeIn,
                child: Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 51,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                builder: (context, value1, child) {
                  return TweenAnimationBuilder(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 600),
                    curve: Curves.easeIn,
                    child: child!,
                    builder:
                        (BuildContext context, double value, Widget? child) {
                      return Transform.translate(
                        offset: Offset(0, -value1 * 100),
                        child: Opacity(opacity: value, child: child!),
                      );
                    },
                  );
                },
              ),
              22.height,
              Text(
                "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Colors.white54,
                ),
              ),
              86.height,
              Container(
                height: 49,
                decoration: BoxDecoration(
                  // color: Colors.white,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0.1, 0.9],
                    tileMode: TileMode.clamp,
                    colors: [
                      Colors.white.withOpacity(0.4),
                      Colors.white.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
