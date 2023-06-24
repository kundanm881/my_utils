import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  /// [_getMedia] is get mediaquery
  MediaQueryData _getMedia(BuildContext context) => MediaQuery.of(context);

  /// [viewPadding] geting view padding
  EdgeInsets get viewPadding => _getMedia(this).viewPadding;

  /// [size] getting size of application
  Size get screenSize => _getMedia(this).size;

  /// [size] getting width of application
  double get screenWidth => screenSize.width;

  /// [size] getting height of application
  double get screenHeight => screenSize.height;

  /// [theme] getting theme of application
  ThemeData get appTheme => Theme.of(this);
}

extension WidgetExtension on num {
  ///  [_number] is returing [double] value.
  double _number() => this.toDouble();

  /// this is sizebox widget with height property
  Widget get height => SizedBox(height: _number());

  /// this is sizebox widget with width property
  Widget get width => SizedBox(width: _number());
}
