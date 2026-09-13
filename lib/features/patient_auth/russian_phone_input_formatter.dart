import 'package:flutter/services.dart';

/// Formats only the ten national digits. The field renders +7 separately.
class RussianPhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = _digits(newValue.text);
    final cursor = newValue.selection.isValid
        ? newValue.selection.extentOffset.clamp(0, newValue.text.length)
        : newValue.text.length;
    var digitsBeforeCursor = _digits(newValue.text.substring(0, cursor)).length;

    // Strip a country/trunk prefix only from a pasted full number, never
    // from a national number being typed (which can itself start with 7/8).
    final isPaste =
        oldValue.text.isEmpty ||
        newValue.text.length - oldValue.text.length > 1 ||
        !oldValue.selection.isCollapsed;
    if (isPaste &&
        digits.length == 11 &&
        (digits.startsWith('7') || digits.startsWith('8'))) {
      digits = digits.substring(1);
      digitsBeforeCursor = (digitsBeforeCursor - 1).clamp(0, digits.length);
    }

    // Backspace/Delete on a mask separator must remove an adjacent digit
    // instead of immediately restoring the separator and trapping the cursor.
    if (digits == _digits(oldValue.text) &&
        oldValue.selection.isCollapsed &&
        newValue.text.length == oldValue.text.length - 1) {
      final backspace = oldValue.selection.extentOffset == cursor + 1;
      final delete = oldValue.selection.extentOffset == cursor;
      final index = backspace ? digitsBeforeCursor - 1 : digitsBeforeCursor;
      if ((backspace || delete) && index >= 0 && index < digits.length) {
        digits = digits.replaceRange(index, index + 1, '');
        if (backspace) digitsBeforeCursor--;
      }
    }

    if (digits.length > 10) digits = digits.substring(0, 10);
    final formatted = _formatLocalPhone(digits);
    final digitOffset = digitsBeforeCursor.clamp(0, digits.length);
    var offset = 0;
    var count = 0;
    while (offset < formatted.length && count < digitOffset) {
      if (_digits(formatted[offset]).isNotEmpty) count++;
      offset++;
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}

/// Display helper for complete phone numbers, separate from editable text.
String formatRussianPhone(String value) {
  var digits = _digits(value);
  if (digits.length == 11 &&
      (digits.startsWith('7') || digits.startsWith('8'))) {
    digits = digits.substring(1);
  }
  if (digits.length > 10) digits = digits.substring(0, 10);
  final local = _formatLocalPhone(digits);
  return local.isEmpty ? '+7' : '+7 $local';
}

String _digits(String value) => value.replaceAll(RegExp(r'\D'), '');

String _formatLocalPhone(String digits) {
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i == 3) buffer.write(' ');
    if (i == 6 || i == 8) buffer.write('-');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}
