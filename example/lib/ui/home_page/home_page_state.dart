import 'package:flutter/material.dart';

import 'home_page.dart';

abstract class HomePageSate extends State<HomePageView>
    with TickerProviderStateMixin {
  // late AnimationController animationController;
  // late Animation<double> loginLogoAnimation;

  // @override
  // void initState() {
  //   animationController = AnimationController(
  //     vsync: this,
  //     duration: Duration(milliseconds: 300),
  //   );

  //   loginLogoAnimation = Tween<double>(begin: 1, end: 0).animate(
  //     CurvedAnimation(
  //       parent: animationController,
  //       curve: Curves.easeIn,
  //     ),
  //   );

  //   animationController.forward();

  //   super.initState();
  // }
}
