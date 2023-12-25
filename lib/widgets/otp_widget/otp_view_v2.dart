import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OTPViewV2 extends StatefulWidget {
  const OTPViewV2({super.key, required this.controller});

  final OTPViewController controller;

  @override
  State<OTPViewV2> createState() => _OTPViewV2State();
}

class _OTPViewV2State extends State<OTPViewV2> {
  final method = SystemChannels.textInput;
  String showKeybord = "TextInput.show";

  final FocusNode focusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: focusNode,
      parentNode: FocusScope.of(context),
      child: InkWell(
        onTap: () async {
          focusNode.requestFocus();
          // if (focusNode.hasFocus) {
          await method.invokeMethod(showKeybord);
          // }
        },
        child: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: (focusNode.hasFocus) ? Colors.pink : Colors.green,
          ),
          alignment: Alignment.center,
          child: Text("${widget.controller.text}"),
        ),
      ),
    );
  }
}

class OTPViewController extends ChangeNotifier {
  String text = "";
  OTPViewController({String? text}) {
    this.text = text ?? this.text;
  }
}
