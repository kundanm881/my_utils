import 'dart:convert';
import 'package:flutter/material.dart';
import 'signature_controller.dart';
import 'signature_pad_view.dart';

/// Interactive Signature Drawing Pad and Image Upload Dialog.
/// Allows drawing a signature or selecting an image file,
/// returning the result as a Base64 encoded PNG string.
class SignaturePadDialog extends StatefulWidget {
  final String? initialSignature;
  final String title;
  final String? subtitle;
  final Future<String?> Function()? onPickImage;
  final Color? penColor;
  final double penStrokeWidth;
  final double exportWidth;
  final double exportHeight;

  /// Optional global image picker provider (e.g. from image_picker or file_picker)
  static Future<String?> Function()? defaultOnPickImage;

  const SignaturePadDialog({
    super.key,
    this.initialSignature,
    this.title = 'Digital Signature',
    this.subtitle,
    this.onPickImage,
    this.penColor,
    this.penStrokeWidth = 3.0,
    this.exportWidth = 500,
    this.exportHeight = 220,
  });

  /// Helper to render a signature (Base64 string or URL) safely.
  /// Automatically adapts signature stroke color to the active theme (isDark)
  /// or applies a customized [inkColor].
  static Widget buildSignatureImage(
    String signature, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    Color? fallbackColor,
    Color? inkColor,
    bool? isDark,
  }) {
    if (signature.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final Color? effectiveInkColor = inkColor ??
        (isDark != null
            ? (isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A))
            : null);

    final trimmed = signature.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return Image.network(
        trimmed,
        width: width,
        height: height,
        fit: fit,
        color: effectiveInkColor,
        colorBlendMode: effectiveInkColor != null ? BlendMode.srcIn : null,
        errorBuilder: (_, __, ___) => Icon(
          Icons.broken_image_rounded,
          size: height ?? 24,
          color: fallbackColor ?? Colors.grey,
        ),
      );
    }

    try {
      String base64Str = trimmed;
      if (base64Str.contains(',')) {
        base64Str = base64Str.split(',').last;
      }
      final bytes = base64Decode(base64Str);
      return Image.memory(
        bytes,
        width: width,
        height: height,
        fit: fit,
        color: effectiveInkColor,
        colorBlendMode: effectiveInkColor != null ? BlendMode.srcIn : null,
        errorBuilder: (_, __, ___) => Icon(
          Icons.broken_image_rounded,
          size: height ?? 24,
          color: fallbackColor ?? Colors.grey,
        ),
      );
    } catch (e) {
      return Icon(
        Icons.draw_rounded,
        size: height ?? 24,
        color: fallbackColor ?? Colors.grey,
      );
    }
  }

  /// Show the signature dialog and return the resulting Base64 string or null if cancelled.
  static Future<String?> show(
    BuildContext context, {
    String? initialSignature,
    String title = 'Digital Signature',
    String? subtitle,
    Future<String?> Function()? onPickImage,
    Color? penColor,
    double penStrokeWidth = 3.0,
    double exportWidth = 500,
    double exportHeight = 220,
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => SignaturePadDialog(
        initialSignature: initialSignature,
        title: title,
        subtitle: subtitle,
        onPickImage: onPickImage,
        penColor: penColor,
        penStrokeWidth: penStrokeWidth,
        exportWidth: exportWidth,
        exportHeight: exportHeight,
      ),
    );
  }

  @override
  State<SignaturePadDialog> createState() => _SignaturePadDialogState();
}

class _SignaturePadDialogState extends State<SignaturePadDialog> {
  late final SignatureController _controller;
  String? _pickedBase64;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = SignatureController(
      penStrokeWidth: widget.penStrokeWidth,
    );

    if (widget.initialSignature != null && widget.initialSignature!.trim().isNotEmpty) {
      _pickedBase64 = widget.initialSignature!.trim();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    setState(() {
      _controller.clear();
      _pickedBase64 = null;
    });
  }

  void _undo() {
    setState(() {
      _controller.undo();
      if (_controller.isEmpty && widget.initialSignature != null) {
        _pickedBase64 = widget.initialSignature!.trim();
      }
    });
  }

  Future<void> _handlePickImage() async {
    final picker = widget.onPickImage ?? SignaturePadDialog.defaultOnPickImage;
    if (picker == null) return;

    try {
      final base64String = await picker();
      if (base64String != null && base64String.isNotEmpty) {
        setState(() {
          _controller.clear();
          _pickedBase64 = base64String;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load image: $e')),
        );
      }
    }
  }

  Future<void> _save() async {
    if (_pickedBase64 != null && _controller.isEmpty) {
      Navigator.of(context).pop(_pickedBase64);
      return;
    }

    if (_controller.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please draw your signature first or upload an image.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final base64Png = await _controller.toBase64Png(
        width: widget.exportWidth,
        height: widget.exportHeight,
      );

      if (mounted && base64Png != null) {
        Navigator.of(context).pop(base64Png);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to render signature: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Adapt pen color dynamically if not explicitly specified
    _controller.penColor = widget.penColor ??
        (isDark ? const Color(0xFF38BDF8) : const Color(0xFF0F172A));

    final canPickImage = widget.onPickImage != null || SignaturePadDialog.defaultOnPickImage != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.draw_rounded,
                              size: 20,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              widget.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.subtitle ??
                      (canPickImage
                          ? 'Draw your authorized signature below or upload an image from your files.'
                          : 'Draw your authorized signature in the area below.'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),

                // Signature Pad Canvas or Uploaded Image Preview
                if (_pickedBase64 != null && _controller.isEmpty)
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? Colors.white12 : Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: SignaturePadDialog.buildSignatureImage(
                          _pickedBase64!,
                          height: 140,
                          fit: BoxFit.contain,
                          isDark: isDark,
                        ),
                      ),
                    ),
                  )
                else
                  SignaturePadView(
                    controller: _controller,
                    height: 200,
                  ),

                const SizedBox(height: 16),

                // Responsive Action Toolbar
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 10,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _clear,
                          icon: const Icon(Icons.delete_outline_rounded, size: 16),
                          label: const Text('Clear'),
                          style: OutlinedButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: _undo,
                          icon: const Icon(Icons.undo_rounded, size: 16),
                          label: const Text('Undo'),
                          style: OutlinedButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        if (canPickImage)
                          OutlinedButton.icon(
                            onPressed: _handlePickImage,
                            icon: const Icon(Icons.upload_file_rounded, size: 16),
                            label: const Text('Upload'),
                            style: OutlinedButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                      ],
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        FilledButton.icon(
                          onPressed: _isSaving ? null : _save,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.check_rounded, size: 16),
                          label: const Text('Save Signature'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
