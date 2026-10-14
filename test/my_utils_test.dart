import 'package:flutter_test/flutter_test.dart';
import 'package:kd_utils/methods/get_week_day.dart';
import 'package:kd_utils/methods/time_stamp.dart';
import 'package:kd_utils/formatters/currency_input_formatter.dart';

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

  group('CurrencyInputFormatter tests', () {
    test('format Indian numbers correctly', () {
      expect(CurrencyInputFormatter.format(0), '0');
      expect(CurrencyInputFormatter.format(1000), '1,000');
      expect(CurrencyInputFormatter.format(50000), '50,000');
      expect(CurrencyInputFormatter.format(150000), '1,50,000');
      expect(CurrencyInputFormatter.format(10000000), '1,00,00,000');
    });

    test('parse currency strings correctly', () {
      expect(CurrencyInputFormatter.parse('1,50,000'), 150000.0);
      expect(CurrencyInputFormatter.parse('₹ 50,000'), 50000.0);
      expect(CurrencyInputFormatter.parse(''), 0.0);
      expect(CurrencyInputFormatter.parse(null), 0.0);
    });

    test('converts amounts to Indian words correctly', () {
      expect(CurrencyInputFormatter.toWords(0), 'Zero Rupees');
      expect(CurrencyInputFormatter.toWords(150000),
          'One Lakh Fifty Thousand Rupees');
    });
  });
}
