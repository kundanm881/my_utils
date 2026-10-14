import 'package:flutter_test/flutter_test.dart';
import 'package:kd_utils/methods/get_week_day.dart';
import 'package:kd_utils/methods/time_stamp.dart';

void main() {
  group('getWeekDay tests', () {
    test('returns full weekday names correctly', () {
      expect(getWeekDay(1), 'Monday');
      expect(getWeekDay(7), 'Sunday');
    });

    test('returns short weekday names correctly', () {
      expect(getWeekDay(1, short: true), 'Mon');
      expect(getWeekDay(7, short: true), 'Sun');
    });

    test('handles invalid weekday values', () {
      expect(getWeekDay(0), 'Day Not Found');
      expect(getWeekDay(8), 'Day Not Found');
      expect(getWeekDay(8, short: true), 'Day Not Found');
    });
  });

  group('timeStampToDateTime tests', () {
    test('converts 10-digit epoch seconds correctly', () {
      final date = timeStampToDateTime('1694160861');
      expect(date.millisecondsSinceEpoch, 1694160861000);
    });

    test('converts 13-digit epoch milliseconds correctly', () {
      final date = timeStampToDateTime('1694160861000');
      expect(date.millisecondsSinceEpoch, 1694160861000);
    });
  });
}
