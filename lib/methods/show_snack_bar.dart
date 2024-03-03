import 'package:flutter/material.dart';

void kSnackBar(BuildContext context, {required String message}) async {
  OverlayEntry entry = OverlayEntry(
    builder: (context) {
      return Text("data");
    },
    maintainState: true,
    // opaque: true,
  );
  OverlayState overlayState = Overlay.of(context);
  overlayState.insert(entry);
  await Future.delayed(Duration(seconds: 2));
  entry.remove();
}
