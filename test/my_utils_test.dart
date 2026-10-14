import 'package:flutter_test/flutter_test.dart';
import 'package:kd_utils/kd_utils.dart';

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

    test('formatCurrency and formatRupees format properly', () {
      expect(formatCurrency(50000), '₹ 50,000');
      expect(formatCurrency(150000), '₹ 1.50 L');
      expect(formatCurrency(10000000), '₹ 1.00 Cr');
      expect(formatCurrency(150000, compact: false), '₹ 1,50,000');
      expect(formatRupees(50000), '₹ 50,000');
      expect(formatRupees(-5000), '- ₹ 5,000');
      expect(150000.toRupees(), '₹ 1,50,000');
      expect(150000.toCurrency(), '₹ 1.50 L');
    });
  });

  group('Date and Month Formatter tests', () {
    test('getCurrentMonthName and getMonthName return correct month', () {
      expect(getMonthName(1), 'January');
      expect(getMonthName(12), 'December');
      expect(getMonthName(13), '');

      final date = DateTime(2026, 10, 15);
      expect(getCurrentMonthName(date), 'October');
    });

    test('formatDate, formatDateShort, formatDateVerbose format correctly', () {
      final date = DateTime(2026, 9, 26);
      expect(formatDate(date), '26 Sep 2026');
      expect(formatDate(null), 'N/A');
      expect(formatDate(null, fallback: '--'), '--');

      expect(formatDateShort(date), '26/09/2026');
      expect(formatDateShort(null), 'N/A');

      expect(formatDateVerbose(date), 'Sat, 26 Sep 2026');
      expect(formatDateVerbose(null), 'N/A');
    });

    test('DateTimeExtension methods work seamlessly', () {
      final date = DateTime(2026, 9, 26);
      expect(date.toFormattedDate(), '26 Sep 2026');
      expect(date.toFormattedDateShort(), '26/09/2026');
      expect(date.toFormattedDateVerbose(), 'Sat, 26 Sep 2026');
      expect(date.monthFullName, 'September');
    });
  });

  group('PlatformHelper tests', () {
    test('AppPlatform provides valid properties', () {
      expect(AppPlatform.operatingSystemName, isNotEmpty);
      expect(AppPlatform.platformIcon, isNotNull);
      expect(PlatformHelper.operatingSystemName, AppPlatform.operatingSystemName);
      expect(KdPlatform.isWeb, AppPlatform.isWeb);
    });
  });
}


