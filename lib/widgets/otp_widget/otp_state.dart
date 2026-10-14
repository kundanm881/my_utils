import 'package:flutter/material.dart';

import 'otp_view.dart';

abstract class OTPViewState extends State<OTPView> {
  late List<FocusNode> focusNodes;
  late List<TextEditingController> otpFieldControllers;
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _genNodesAndController();
  }

  @override
  void dispose() {
    for (final node in focusNodes) {
      node.dispose();
    }
    for (final c in otpFieldControllers) {
      c.dispose();
    }
    controller.dispose();
    super.dispose();
  }

  void _genNodesAndController() {
    focusNodes = List.generate(widget.otpCount, (_) => FocusNode());
    otpFieldControllers =
        List.generate(widget.otpCount, (_) => TextEditingController());
  }

  void _addText(String t) {
    controller.text = controller.text + t;
  }

  void _removeText() {
    final textLength = controller.text.length;
    if (textLength > 0) {
      controller.text = controller.text.substring(0, textLength - 1);
    }
  }

  void onChange({
    required int currentIndex,
  }) {
    final ct = otpFieldControllers[currentIndex];
    if (ct.text.isEmpty) {
      _removeText();
      if (currentIndex > 0) {
        focusNodes[currentIndex - 1].requestFocus();
      }
    } else {
      _addText(ct.text);
      if (currentIndex < widget.otpCount - 1) {
        focusNodes[currentIndex + 1].requestFocus();
      } else {
        focusNodes[currentIndex].unfocus();
        widget.onSubmit?.call(controller.text);
      }
    }
  }
}
