import 'package:flutter/material.dart';

/// Displays a floating overlay snackbar / toast message.
///
/// Falls back to [ScaffoldMessenger] if no [Overlay] is found in the current context.
void kSnackBar(
  BuildContext context, {
  required String message,
  Duration duration = const Duration(seconds: 2),
  Color? backgroundColor,
  TextStyle? textStyle,
  EdgeInsetsGeometry? padding,
  BorderRadiusGeometry? borderRadius,
  Alignment alignment = Alignment.bottomCenter,
}) async {
  final overlayState = Overlay.maybeOf(context);
  if (overlayState == null) {
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text(message, style: textStyle),
        duration: duration,
        backgroundColor: backgroundColor,
      ),
    );
    return;
  }

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => SafeArea(
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: padding ??
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: backgroundColor ?? Colors.black87,
                borderRadius: borderRadius ?? BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: textStyle ??
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  overlayState.insert(entry);
  await Future.delayed(duration);
  if (entry.mounted) {
    entry.remove();
  }
}
