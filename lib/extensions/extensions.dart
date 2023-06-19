
import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  MediaQueryData _getMedia(BuildContext context) => MediaQuery.of(context);

  /// [_getMedia] is get mediaquery

  EdgeInsets get viewPadding => _getMedia(this).viewPadding;

  Size get screenSize => _getMedia(this).size;

  double get screenWidth => screenSize.width;

  double get screenHeight => screenSize.height;

  ThemeData get theme => Theme.of(this);
}

extension WidgetExtension on num {
  double _number() => this.toDouble();

  ///  [num] is the value type [this] take value of [num]  1.

  Widget get height => SizedBox(height: _number());

  Widget get width => SizedBox(width: _number());
}
