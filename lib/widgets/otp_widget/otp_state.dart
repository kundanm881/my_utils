import 'package:flutter/material.dart';

import 'otp_view.dart';

abstract class OTPViewState extends State<OTPView> {
  late List<FocusNode> focusNodes;
  late List<TextEditingController> otpFieldControllers;
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    _genNodesAndController();

    super.initState();
  }

  _genNodesAndController() {
    List<FocusNode> tempNodes = [];
    List<TextEditingController> tempController = [];
    for (int i = 0; i < widget.otpCount; i++) {
      tempNodes.add(FocusNode());
      tempController.add(TextEditingController());
    }
    setState(() {
      focusNodes = tempNodes;
      otpFieldControllers = tempController;
    });
  }

  _addText(String t) {
    controller.text = controller.text + t;
  }

  _removeText() {
    int textLength = controller.text.length;
    controller.text = controller.text.substring(0, textLength - 1);
  }

  onChange({
    required int currentIndex,
  }) {
    final ct = otpFieldControllers[currentIndex];
    // if (currentIndex > 0) {}
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
        widget.onSubmit!(controller.text);
      }
    }
  }
}
