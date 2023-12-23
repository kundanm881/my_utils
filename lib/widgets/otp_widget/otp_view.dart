import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kd_utils/extensions/extensions.dart';

final RegExp numberReg = RegExp(r'[0-9]');

class OTPView extends StatefulWidget {
  const OTPView({
    super.key,
    this.otpCount = 6,
    this.controller,
    this.onSubmit,
  });
  final int otpCount;
  final TextEditingController? controller;
  final Function(String otp)? onSubmit;
  @override
  State<OTPView> createState() => _OTPViewState();
}

class _OTPViewState extends State<OTPView> {
  late List<FocusNode> focusNodes;
  FocusNode keybordFocus = FocusNode();
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    _genNodesAndController();

    super.initState();
  }

  _genNodesAndController() {
    List<FocusNode> tempNodes = [];
    for (int i = 0; i < widget.otpCount; i++) {
      tempNodes.add(FocusNode());
    }
    setState(() {
      focusNodes = tempNodes;
    });
  }

  changeFocuse(String v, {required FocusNode currentNode, required int index}) {
    if (v.isNotEmpty) {
      _addText(v);
      if (currentNode == focusNodes.last) {
        FocusScope.of(context).unfocus();
        if (widget.onSubmit != null) {
          widget.onSubmit!(controller.text);
        }
      } else {
        focusNodes[index + 1].requestFocus();
      }
    } else {
      _removeText();
      if (currentNode != focusNodes.first) {
        focusNodes[index - 1].requestFocus();
      }
    }
    widget.controller?.text = controller.text;
  }

  onBackspaceClick() {
    int focusIndex = controller.text.length;

    log(focusIndex.toString());
    if (focusIndex != widget.otpCount) {
      final currentfocus = focusNodes[focusIndex];
      if (currentfocus != focusNodes.first) {
        focusNodes[focusIndex - 1].requestFocus();
      }
    }
  }

  _addText(String t) {
    controller.text = controller.text + t;
  }

  _removeText() {
    int textLength = controller.text.length;
    controller.text = controller.text.substring(0, textLength - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.otpCount,
        (index) {
          final node = focusNodes[index];

          if (index < widget.otpCount - 1) {
            return Row(
              children: [
                OtpTextFeild(
                  keybordfocus: keybordFocus,
                  focusNode: node,
                  onChanged: (v) =>
                      changeFocuse(v, currentNode: node, index: index),
                  onBackSpace: (n, event) {
                    if (event.isKeyPressed(LogicalKeyboardKey.backspace)) {
                      //
                      onBackspaceClick();
                    }
                    return KeyEventResult.ignored;
                  },
                  onSubmit: (v) {
                    if (widget.onSubmit != null) {
                      widget.onSubmit!(controller.text);
                    }
                  },
                ),
                10.width,
              ],
            );
          } else {
            return OtpTextFeild(
              keybordfocus: keybordFocus,
              focusNode: node,
              onChanged: (v) =>
                  changeFocuse(v, currentNode: node, index: index),
              onBackSpace: (n, event) {
                if (event.isKeyPressed(LogicalKeyboardKey.backspace)) {
                  //
                  onBackspaceClick();
                }
                return KeyEventResult.ignored;
              },
              onSubmit: (v) {
                if (widget.onSubmit != null) {
                  widget.onSubmit!(controller.text);
                }
              },
            );
          }
        },
      ),
    );
  }
}

class OtpTextFeild extends StatelessWidget {
  const OtpTextFeild({
    super.key,
    this.focusNode,
    this.onChanged,
    this.controller,
    this.keybordfocus,
    this.onBackSpace,
    this.onSubmit,
  });
  final FocusNode? focusNode;
  final FocusNode? keybordfocus;
  final TextEditingController? controller;
  final Function(String v)? onChanged;
  final Function(String v)? onSubmit;
  final KeyEventResult Function(FocusNode node, RawKeyEvent event)? onBackSpace;

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: keybordfocus,
      onKey: onBackSpace,
      child: TextField(
        focusNode: focusNode,
        maxLength: 1,
        textAlignVertical: TextAlignVertical.center,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          constraints: BoxConstraints(maxWidth: 50, maxHeight: 50),
          isDense: true,
          counterText: "",
        ),
        textInputAction: TextInputAction.done,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.allow(numberReg)],
        onChanged: onChanged,
        onSubmitted: onSubmit,
      ),
    );
  }
}
