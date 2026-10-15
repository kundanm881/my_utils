import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kd_utils/kd_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SignatureController Tests', () {
    test('Initial state is empty', () {
      final controller = SignatureController();
      expect(controller.isEmpty, isTrue);
      expect(controller.isNotEmpty, isFalse);
      expect(controller.strokes, isEmpty);
      expect(controller.strokeCount, 0);
    });

    test('Adding strokes updates state', () {
      final controller = SignatureController(penColor: Colors.blue, penStrokeWidth: 4.0);
      expect(controller.penColor, Colors.blue);
      expect(controller.strokeWidth, 4.0);

      controller.startStroke(const Offset(10, 10));
      controller.addPoint(const Offset(20, 20));
      controller.endStroke();

      expect(controller.isEmpty, isFalse);
      expect(controller.isNotEmpty, isTrue);
      expect(controller.strokeCount, 1);
      expect(controller.strokes.first.length, 2);
    });

    test('Undo removes last stroke', () {
      final controller = SignatureController();
      controller.startStroke(const Offset(10, 10));
      controller.endStroke();
      controller.startStroke(const Offset(30, 30));
      controller.endStroke();
      expect(controller.strokeCount, 2);

      controller.undo();
      expect(controller.strokeCount, 1);

      controller.undo();
      expect(controller.isEmpty, isTrue);
    });

    test('Clear removes all strokes', () {
      final controller = SignatureController();
      controller.startStroke(const Offset(10, 10));
      controller.endStroke();
      controller.startStroke(const Offset(20, 20));
      controller.endStroke();

      controller.clear();
      expect(controller.isEmpty, isTrue);
      expect(controller.strokeCount, 0);
    });

    test('Export produces image and bytes', () async {
      final controller = SignatureController();
      controller.startStroke(const Offset(10, 10));
      controller.addPoint(const Offset(50, 50));
      controller.endStroke();

      final bytes = await controller.toPngBytes(width: 100, height: 100);
      expect(bytes, isNotNull);
      expect(bytes!.isNotEmpty, isTrue);

      final base64Png = await controller.toBase64Png(width: 100, height: 100);
      expect(base64Png, isNotNull);
      expect(base64Png!.isNotEmpty, isTrue);
    });
  });

  group('SignaturePadDialog buildSignatureImage Tests', () {
    testWidgets('Renders empty for blank string', (tester) async {
      final widget = SignaturePadDialog.buildSignatureImage('');
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
      expect(find.byType(SizedBox), findsOneWidget);
    });
  });
}
