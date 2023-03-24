
import 'package:flutter/cupertino.dart';

extension ViewPadding on BuildContext {
  EdgeInsets get viewPadding => MediaQuery.of(this).viewPadding;
}