import 'package:flutter/material.dart';
import 'signature_controller.dart';

/// Interactive Signature Drawing Pad widget.
/// Renders strokes from a [SignatureController] and captures touch/mouse gestures.
class SignaturePadView extends StatelessWidget {
  final SignatureController controller;
  final double? width;
  final double height;
  final Color? backgroundColor;
  final BoxDecoration? decoration;
  final bool showGuideline;
  final String? guidelineText;
  final Color? guidelineColor;
  final Widget? placeholder;
  final Widget? overlay;

  const SignaturePadView({
    super.key,
    required this.controller,
    this.width,
    this.height = 200,
    this.backgroundColor,
    this.decoration,
    this.showGuideline = true,
    this.guidelineText = 'X ____________________________ Sign above this line',
    this.guidelineColor,
    this.placeholder,
    this.overlay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final effectiveBg = backgroundColor ??
        (isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC));

    final effectiveDecoration = decoration ??
        BoxDecoration(
          color: effectiveBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.grey.shade300,
            width: 1.5,
          ),
        );

    final effectiveGuidelineColor = guidelineColor ??
        (isDark ? Colors.white24 : Colors.grey.shade400);

    return Container(
      width: width,
      height: height,
      decoration: effectiveDecoration,
      child: ClipRRect(
        borderRadius: effectiveDecoration.borderRadius?.resolve(Directionality.of(context)) ??
            BorderRadius.circular(10),
        child: Stack(
          children: [
            // Guideline
            if (showGuideline) ...[
              Positioned(
                bottom: 40,
                left: 24,
                right: 24,
                child: Container(
                  height: 1,
                  color: effectiveGuidelineColor.withValues(alpha: 0.6),
                ),
              ),
              if (guidelineText != null && guidelineText!.isNotEmpty)
                Positioned(
                  bottom: 18,
                  left: 24,
                  child: Text(
                    guidelineText!,
                    style: TextStyle(
                      fontSize: 10,
                      color: effectiveGuidelineColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],

            // Placeholder (shown when empty and provided)
            if (placeholder != null)
              AnimatedBuilder(
                animation: controller,
                builder: (context, _) {
                  return controller.isEmpty ? placeholder! : const SizedBox.shrink();
                },
              ),

            // Drawing canvas
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: (details) {
                controller.startStroke(details.localPosition);
              },
              onPanUpdate: (details) {
                controller.addPoint(details.localPosition);
              },
              onPanEnd: (_) {
                controller.endStroke();
              },
              child: AnimatedBuilder(
                animation: controller,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _SignaturePadPainter(
                      strokes: controller.strokes,
                      penColor: controller.penColor,
                      strokeWidth: controller.strokeWidth,
                    ),
                    size: Size.infinite,
                  );
                },
              ),
            ),

            // Optional overlay
            if (overlay != null) overlay!,
          ],
        ),
      ),
    );
  }
}

class _SignaturePadPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final Color penColor;
  final double strokeWidth;

  _SignaturePadPainter({
    required this.strokes,
    required this.penColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = penColor
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.isEmpty) continue;
      if (stroke.length == 1) {
        canvas.drawCircle(stroke.first, strokeWidth / 2, paint..style = PaintingStyle.fill);
        paint.style = PaintingStyle.stroke;
      } else {
        final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
        for (int i = 1; i < stroke.length; i++) {
          path.lineTo(stroke[i].dx, stroke[i].dy);
        }
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePadPainter oldDelegate) => true;
}
