import 'package:flutter/material.dart';
extension Number on num{
  Widget get h => SizedBox(height: double.parse("$this"));
  Widget get w => SizedBox(width: double.parse("$this"));

}

