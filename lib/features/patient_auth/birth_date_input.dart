import 'package:flutter/services.dart';

abstract final class BirthDateInput {
  static const _maximumLength = 8;

  static bool canAppendDigit(
    String currentDigits,
    String digit, {
    DateTime? now,
  }) {
    if (!RegExp(r'^[0-9]$').hasMatch(digit) ||
        currentDigits.length >= _maximumLength) {
      return false;
    }

    final candidate = '$currentDigits$digit';
    final day = _numberAt(candidate, 0, 2);
    if (candidate.length >= 2 && (day == null || day < 1 || day > 31)) {
      return false;
    }

    final month = _numberAt(candidate, 2, 4);
    if (candidate.length >= 4 && (month == null || month < 1 || month > 12)) {
      return false;
    }

    if (day != null && month != null && day > _maximumDay(month)) {
      return false;
    }

    return candidate.length < _maximumLength ||
        isCompleteValid(candidate, now: now);
  }

  static bool isCompleteValid(String digits, {DateTime? now}) {
    if (!RegExp(r'^\d{8}$').hasMatch(digits)) {
      return false;
    }

    final day = int.parse(digits.substring(0, 2));
    final month = int.parse(digits.substring(2, 4));
    final year = int.parse(digits.substring(4, 8));
    final date = DateTime(year, month, day);
    final today = now ?? DateTime.now();

    return year >= 1900 &&
        date.year == year &&
        date.month == month &&
        date.day == day &&
        !date.isAfter(DateTime(today.year, today.month, today.day));
  }

  static String format(String digits) {
    if (digits.length <= 2) {
      return digits;
    }
    if (digits.length <= 4) {
      return '${digits.substring(0, 2)}.${digits.substring(2)}';
    }
    return '${digits.substring(0, 2)}.${digits.substring(2, 4)}.${digits.substring(4)}';
  }

  static String digits(String value) => value.replaceAll(RegExp(r'\D'), '');

  static int? _numberAt(String digits, int start, int end) {
    if (digits.length < end) {
      return null;
    }
    return int.parse(digits.substring(start, end));
  }

  static int _maximumDay(int month) {
    return switch (month) {
      2 => 29,
      4 || 6 || 9 || 11 => 30,
      _ => 31,
    };
  }
}

/// Keeps native text editing while preventing impossible calendar dates.
class BirthDateInputFormatter extends TextInputFormatter {
  BirthDateInputFormatter({DateTime Function()? clock}) : _now = clock;

  final DateTime Function()? _now;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final rawDigits = BirthDateInput.digits(newValue.text);
    final oldDigits = BirthDateInput.digits(oldValue.text);
    final isDeletion = rawDigits.length < oldDigits.length;

    var accepted = '';
    for (final digit in rawDigits.split('')) {
      if (!BirthDateInput.canAppendDigit(accepted, digit, now: _now?.call())) {
        if (!isDeletion) {
          break;
        }
      } else {
        accepted = '$accepted$digit';
      }
    }

    final formatted = BirthDateInput.format(accepted);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
