import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kd_utils/kd_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LabourDayAttendance Model Tests', () {
    test('Default values are correct', () {
      const rec = LabourDayAttendance(day: 1);
      expect(rec.day, 1);
      expect(rec.present, isFalse);
      expect(rec.absent, isFalse);
      expect(rec.halfDay, isFalse);
      expect(rec.overtime, 0.0);
      expect(rec.advance, 0.0);
      expect(rec.signature, isNull);
    });

    test('copyWith updates fields correctly', () {
      const rec = LabourDayAttendance(day: 1);
      final updated = rec.copyWith(present: true, overtime: 2.5, advance: 500);
      expect(updated.day, 1);
      expect(updated.present, isTrue);
      expect(updated.overtime, 2.5);
      expect(updated.advance, 500);
    });
  });

  group('LabourAttendanceCard Widget Tests', () {
    testWidgets('Renders worker metadata and table', (tester) async {
      final now = DateTime(2026, 10, 1);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: LabourAttendanceCard(
                workerName: 'Ramesh Kumar',
                workerRole: 'Mason',
                dailyWage: 800,
                month: now,
                dayAttendance: const {
                  1: LabourDayAttendance(day: 1, present: true, overtime: 2.0),
                  2: LabourDayAttendance(day: 2, absent: true),
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('MONTHLY ATTENDANCE & OVERTIME CARD'), findsOneWidget);
      expect(find.text('RAMESH KUMAR'), findsOneWidget);
      expect(find.text('MASON'), findsOneWidget);
    });
  });
}
