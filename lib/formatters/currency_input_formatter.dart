import 'dart:math';
import 'package:flutter/services.dart';

/// Formats numeric input in real-time according to the Indian currency numbering system
/// (e.g., 1,000; 10,000; 1,00,000; 10,00,000; 1,00,00,000).
///
/// Features:
/// - Dynamic Indian comma formatting as user types.
/// - Preserves accurate cursor position during insertions and deletions.
/// - Allows optional decimal input (up to 2 decimal places).
/// - Provides helper methods: [format], [parse], and [toWords].
class CurrencyInputFormatter extends TextInputFormatter {
  final bool allowDecimal;
  final int maxDecimalDigits;

  const CurrencyInputFormatter({
    this.allowDecimal = true,
    this.maxDecimalDigits = 2,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Handle backspace when the cursor was right after a comma:
    // If a comma was deleted by backspacing, also delete the digit immediately preceding it
    String newText = newValue.text;
    int selectionEnd = newValue.selection.end;

    if (oldValue.text.length == newValue.text.length + 1 &&
        oldValue.selection.end > 0 &&
        oldValue.selection.end <= oldValue.text.length) {
      final deletedChar = oldValue.text[oldValue.selection.end - 1];
      if (deletedChar == ',') {
        // User tried to backspace a comma; delete the preceding digit instead
        final beforeComma = oldValue.text.substring(
          0,
          oldValue.selection.end - 1,
        );
        final afterComma = oldValue.text.substring(oldValue.selection.end);
        if (beforeComma.isNotEmpty) {
          newText =
              beforeComma.substring(0, beforeComma.length - 1) + afterComma;
          selectionEnd = max(0, beforeComma.length - 1);
        }
      }
    }

    // Extract valid raw characters
    String cleanText = newText.replaceAll(',', '').trim();
    if (allowDecimal) {
      cleanText = cleanText.replaceAll(RegExp(r'[^0-9.]'), '');
      // Ensure at most one decimal point
      final firstDot = cleanText.indexOf('.');
      if (firstDot != -1) {
        final before = cleanText.substring(0, firstDot + 1);
        final after = cleanText.substring(firstDot + 1).replaceAll('.', '');
        final clampedAfter = after.length > maxDecimalDigits
            ? after.substring(0, maxDecimalDigits)
            : after;
        cleanText = before + clampedAfter;
      }
    } else {
      cleanText = cleanText.replaceAll(RegExp(r'[^0-9]'), '');
    }

    if (cleanText.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Split into integer part and decimal part
    String integerPart = cleanText;
    String decimalPart = '';
    final hasDecimal = cleanText.contains('.');
    if (hasDecimal) {
      final parts = cleanText.split('.');
      integerPart = parts[0];
      decimalPart = parts.length > 1 ? '.${parts[1]}' : '.';
    }

    // Remove leading zeros from integer part (keep '0' if followed by decimal or alone)
    if (integerPart.length > 1 && integerPart.startsWith('0')) {
      integerPart = integerPart.replaceFirst(RegExp(r'^0+'), '');
      if (integerPart.isEmpty) integerPart = '0';
    }

    final formattedInteger = _formatIndianInteger(integerPart);
    final formattedText = formattedInteger + decimalPart;

    // Count raw digits/dots before the original cursor in newText
    int rawCharsBeforeCursor = 0;
    for (int i = 0; i < selectionEnd && i < newText.length; i++) {
      final code = newText.codeUnitAt(i);
      if ((code >= 48 && code <= 57) || (allowDecimal && code == 46)) {
        rawCharsBeforeCursor++;
      }
    }

    // Calculate new cursor offset in formattedText matching rawCharsBeforeCursor
    int newOffset = 0;
    int countedRawChars = 0;
    for (int i = 0; i < formattedText.length; i++) {
      if (countedRawChars >= rawCharsBeforeCursor) {
        break;
      }
      final code = formattedText.codeUnitAt(i);
      if ((code >= 48 && code <= 57) || (allowDecimal && code == 46)) {
        countedRawChars++;
      }
      newOffset = i + 1;
    }

    newOffset = newOffset.clamp(0, formattedText.length);

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }

  /// Formats integer digits using Indian grouping:
  /// The rightmost 3 digits form the first group; subsequent groups consist of 2 digits.
  static String _formatIndianInteger(String digits) {
    if (digits.length <= 3) return digits;
    final lastThree = digits.substring(digits.length - 3);
    final rest = digits.substring(0, digits.length - 3);
    final formattedRest = rest.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{2})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return '$formattedRest,$lastThree';
  }

  /// Format any number into Indian comma format string, e.g. 50000 -> "50,000", 150000.5 -> "1,50,000.5"
  static String format(num amount) {
    if (amount == 0) return '0';
    final isNegative = amount < 0;
    final absAmount = amount.abs();
    final isWhole = absAmount % 1 == 0;

    if (isWhole) {
      final str = absAmount.toInt().toString();
      final formatted = _formatIndianInteger(str);
      return isNegative ? '-$formatted' : formatted;
    } else {
      final str = absAmount.toStringAsFixed(2);
      final parts = str.split('.');
      final formatted = _formatIndianInteger(parts[0]);
      final decimal = parts[1].replaceFirst(RegExp(r'0+$'), '');
      final full = decimal.isEmpty ? formatted : '$formatted.$decimal';
      return isNegative ? '-$full' : full;
    }
  }

  /// Parse user-entered formatted currency string (e.g., "1,50,000" or "₹ 50,000") to double
  static double parse(String? text) {
    if (text == null || text.trim().isEmpty) return 0.0;
    final clean = text.replaceAll(RegExp(r'[^0-9.-]'), '');
    return double.tryParse(clean) ?? 0.0;
  }

  /// Converts a numeric amount into Indian English words (e.g., 150000 -> "One Lakh Fifty Thousand Rupees")
  static String toWords(num amount) {
    try {
      if (amount.isNaN || amount.isInfinite) return '';
      final absVal = amount.abs().floor();
      if (absVal == 0) return 'Zero Rupees';

      // Cap at very large values to prevent scientific notation formatting
      if (absVal > 999999999999999) {
        return 'Amount too large';
      }

      const units = [
        '',
        'One',
        'Two',
        'Three',
        'Four',
        'Five',
        'Six',
        'Seven',
        'Eight',
        'Nine',
        'Ten',
        'Eleven',
        'Twelve',
        'Thirteen',
        'Fourteen',
        'Fifteen',
        'Sixteen',
        'Seventeen',
        'Eighteen',
        'Nineteen',
      ];

      const tens = [
        '',
        '',
        'Twenty',
        'Thirty',
        'Forty',
        'Fifty',
        'Sixty',
        'Seventy',
        'Eighty',
        'Ninety',
      ];

      String twoDigits(int n) {
        if (n <= 0) return '';
        if (n < 20) return units[n];
        final tenIndex = (n ~/ 10).clamp(0, 9);
        final unitIndex = (n % 10).clamp(0, 9);
        final ten = tens[tenIndex];
        final unit = units[unitIndex];
        return unit.isEmpty ? ten : '$ten $unit';
      }

      String threeDigits(int n) {
        if (n <= 0) return '';
        final hundred = (n ~/ 100).clamp(0, 9);
        final rest = n % 100;
        final hundredStr = hundred > 0 ? '${units[hundred]} Hundred' : '';
        final restStr = twoDigits(rest);

        if (hundredStr.isNotEmpty && restStr.isNotEmpty) {
          return '$hundredStr $restStr';
        } else if (hundredStr.isNotEmpty) {
          return hundredStr;
        }
        return restStr;
      }

      // Convert any integer < 1,00,00,000 (1 Crore) into words
      String convertBelowCrore(int n) {
        if (n <= 0) return '';
        final lakhs = (n ~/ 100000) % 100;
        final thousands = (n ~/ 1000) % 100;
        final hundreds = n % 1000;

        final parts = <String>[];
        if (lakhs > 0) parts.add('${twoDigits(lakhs)} Lakh');
        if (thousands > 0) parts.add('${twoDigits(thousands)} Thousand');
        if (hundreds > 0) parts.add(threeDigits(hundreds));
        return parts.join(' ');
      }

      final crores = absVal ~/ 10000000;
      final belowCrore = absVal % 10000000;

      final resultParts = <String>[];

      if (crores > 0) {
        final croreWords = convertBelowCrore(crores);
        if (croreWords.isNotEmpty) {
          resultParts.add('$croreWords Crore');
        } else {
          resultParts.add('${threeDigits(crores % 1000)} Crore');
        }
      }

      if (belowCrore > 0) {
        final belowCroreWords = convertBelowCrore(belowCrore);
        if (belowCroreWords.isNotEmpty) {
          resultParts.add(belowCroreWords);
        }
      }

      final combined = resultParts.where((p) => p.trim().isNotEmpty).join(' ');
      if (combined.isEmpty) return 'Zero Rupees';
      return '$combined Rupees';
    } catch (_) {
      return '';
    }
  }
}
