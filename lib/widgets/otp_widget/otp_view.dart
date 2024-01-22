import 'package:flutter/material.dart';
import 'package:kd_utils/extensions/extensions.dart';

import 'otp_state.dart';
import 'widget/otp_felid.dart';

class OTPView extends StatefulWidget {
  const OTPView({
    super.key,
    this.otpCount = 6,
    this.controller,
    this.onSubmit,
    required this.style,
  });
  final int otpCount;
  final TextEditingController? controller;
  final Function(String otp)? onSubmit;

  final OTPStyle style;
  @override
  State<OTPView> createState() => _OTPViewState();
}

class _OTPViewState extends OTPViewState {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.otpCount,
        (index) {
          final node = focusNodes[index];
          final textController = otpFieldControllers[index];

          return Row(
            children: [
              OtpTextField(
                focusNode: node,
                controller: textController,
                maxHeight: widget.style.maxHeight,
                maxWidth: widget.style.maxWidth,
                isDense: widget.style.isDense,
                cursorColor: widget.style.cursorColor,
                cursorRadius: widget.style.cursorRadius,
                cursorHeight: widget.style.cursorHeight,
                cursorWidth: widget.style.cursorWidth,
                inputBorder: widget.style.inputBorder,
                style: widget.style.style,
                onChanged: (v) => onChange(currentIndex: index),
                onSubmit: (v) {
                  if (widget.onSubmit != null) {
                    widget.onSubmit!(controller.text);
                  }
                },
              ),
              if (index < widget.otpCount - 1) widget.style.space.width,
            ],
          );
        },
      ),
    );
  }
}

class OTPStyle {
  final double maxHeight;
  final double maxWidth;
  final double space;
  final bool isDense;
  final Color? cursorColor;
  final double? cursorHeight;
  final Radius? cursorRadius;
  final double cursorWidth;
  final InputBorder? inputBorder;
  final TextStyle? style;

  OTPStyle({
    this.maxHeight = 50,
    this.maxWidth = 50,
    this.space = 10,
    this.isDense = true,
    this.cursorColor,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorWidth = 2,
    this.inputBorder,
    this.style,
  });
}
