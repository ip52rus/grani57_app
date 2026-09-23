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

    // A native keyboard can report different cursor positions after it removes
    // a formatting separator. Detect the removed character in the old text,
    // rather than inferring it from that platform-specific cursor position.
    // This lets Backspace move through the closing bracket and delete the
    // third, second, and first code digits normally.
    if (digits == _digits(oldValue.text) &&
        newValue.text.length == oldValue.text.length - 1) {
      final removedOffset = _removedCharacterOffset(
        oldValue.text,
        newValue.text,
      );
      final removedCharacter = oldValue.text[removedOffset];
      final digitsBeforeRemovedCharacter = _digits(
        oldValue.text.substring(0, removedOffset),
      ).length;
      final isBackspace =
          oldValue.selection.isCollapsed &&
          oldValue.selection.extentOffset > removedOffset;
      var index = isBackspace
          ? digitsBeforeRemovedCharacter - 1
          : digitsBeforeRemovedCharacter;
      if (index >= digits.length) {
        index = digits.length - 1;
      }
      if (_digits(removedCharacter).isEmpty &&
          index >= 0 &&
          index < digits.length) {
        digits = digits.replaceRange(index, index + 1, '');
        digitsBeforeCursor = isBackspace
            ? digitsBeforeRemovedCharacter - 1
            : digitsBeforeRemovedCharacter;
      }
    }

    if (digits.length > 10) {
      digits = digits.substring(0, 10);
    }
    final formatted = _formatLocalPhone(digits);
    final digitOffset = digitsBeforeCursor.clamp(0, digits.length);
    var offset = 0;
    var count = 0;
    while (offset < formatted.length && count < digitOffset) {
      if (_digits(formatted[offset]).isNotEmpty) count++;
      offset++;
    }
    if (digitOffset == digits.length) {
      offset = formatted.length;
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}

int _removedCharacterOffset(String oldText, String newText) {
  var offset = 0;
  while (offset < newText.length && oldText[offset] == newText[offset]) {
    offset++;
  }
  return offset;
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
  if (digits.isEmpty) {
    return '';
  }
  final buffer = StringBuffer();
  buffer.write('(');
  for (var i = 0; i < digits.length; i++) {
    if (i == 3) {
      buffer
        ..write(')')
        ..write(' ');
    }
    if (i == 6 || i == 8) {
      buffer.write('-');
    }
    buffer.write(digits[i]);
  }
  if (digits.length == 3) {
    buffer.write(')');
  }
  return buffer.toString();
}
