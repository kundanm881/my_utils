import 'package:flutter/material.dart';

extension Number on num {
  ///  [num] is the value type [this] take value of [num]  1.
  Widget get height => SizedBox(height: double.parse("$this"));

  Widget get width => SizedBox(width: double.parse("$this"));
}
