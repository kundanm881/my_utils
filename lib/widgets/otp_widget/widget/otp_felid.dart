import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final RegExp numberReg = RegExp(r'[0-9]');

class OtpTextField extends StatelessWidget {
  const OtpTextField({
    super.key,
    this.focusNode,
    this.onChanged,
    this.controller,
    this.onSubmit,
    this.inputBorder,
    required this.maxWidth,
    required this.maxHeight,
    this.isDense,
    this.style,
    this.cursorColor,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorWidth = 2,
  });

  final FocusNode? focusNode;
  final TextEditingController? controller;
  final Function(String v)? onChanged;
  final Function(String v)? onSubmit;
  final InputBorder? inputBorder;
  final double maxWidth;
  final double maxHeight;
  final bool? isDense;
  final TextStyle? style;
  final Color? cursorColor;
  final double? cursorHeight;
  final Radius? cursorRadius;
  final double cursorWidth;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      style: style,
      cursorColor: cursorColor,
      cursorHeight: cursorHeight,
      cursorWidth: cursorWidth,
      cursorRadius: cursorRadius,
      textAlignVertical: TextAlignVertical.center,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        border: inputBorder,
        focusedBorder: inputBorder,
        isDense: isDense,
        counterText: "",
      ),
      textInputAction: TextInputAction.done,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(numberReg),
        LengthLimitingTextInputFormatter(1)
      ],
      onChanged: onChanged,
      onSubmitted: onSubmit,
    );
  }

  // OutlineInputBorder outlineInputBorder =
}
