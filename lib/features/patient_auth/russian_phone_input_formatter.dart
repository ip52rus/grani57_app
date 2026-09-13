import 'package:flutter/services.dart';

class RussianPhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = formatRussianPhone(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

String formatRussianPhone(String value) {
  var digits = value.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('8')) {
    digits = '7${digits.substring(1)}';
  } else if (digits.length == 10) {
    digits = '7$digits';
  } else if (digits.isEmpty) {
    digits = '7';
  }

  if (!digits.startsWith('7')) {
    digits = '7$digits';
  }

  if (digits.length > 11) {
    digits = digits.substring(0, 11);
  }

  final buffer = StringBuffer('+7');
  final local = digits.length > 1 ? digits.substring(1) : '';

  if (local.isNotEmpty) {
    buffer.write(' ');
    buffer.write(local.substring(0, _cap(local.length, 3)));
  }
  if (local.length > 3) {
    buffer.write(' ');
    buffer.write(local.substring(3, _cap(local.length, 6)));
  }
  if (local.length > 6) {
    buffer.write('-');
    buffer.write(local.substring(6, _cap(local.length, 8)));
  }
  if (local.length > 8) {
    buffer.write('-');
    buffer.write(local.substring(8, _cap(local.length, 10)));
  }

  return buffer.toString();
}

int _cap(int value, int max) => value > max ? max : value;
