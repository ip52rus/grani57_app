import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grani57_app/core/design_system/theme/app_theme.dart';
import 'package:grani57_app/features/patient_auth/birth_date_input.dart';
import 'package:grani57_app/features/patient_auth/patient_phone_login_screen.dart';
import 'package:grani57_app/features/patient_auth/russian_phone_input_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';

TextEditingValue _value(String text, [int? cursor]) => TextEditingValue(
  text: text,
  selection: TextSelection.collapsed(offset: cursor ?? text.length),
);

String _digits(String text) => text.replaceAll(RegExp(r'\D'), '');

void main() {
  final formatter = RussianPhoneInputFormatter();

  for (final phone in ['9990000001', '7990000001', '8990000001']) {
    test('types and backspaces all ten national digits: $phone', () {
      var value = _value('');
      for (var i = 0; i < phone.length; i++) {
        value = formatter.formatEditUpdate(
          value,
          _value(value.text + phone[i]),
        );
        expect(_digits(value.text), phone.substring(0, i + 1));
        expect(value.selection.extentOffset, value.text.length);
      }
      final full = value;
      value = formatter.formatEditUpdate(value, _value('${value.text}5'));
      expect(value.text, full.text);
      for (var i = phone.length - 1; i >= 0; i--) {
        value = formatter.formatEditUpdate(
          value,
          _value(value.text.substring(0, value.text.length - 1)),
        );
        expect(_digits(value.text), phone.substring(0, i));
        expect(value.selection.extentOffset, value.text.length);
      }
      expect(value.text, isEmpty);
    });
  }

  test('pastes local, international and trunk formats without duplicate 7', () {
    for (final input in [
      '9990000001',
      '+79990000001',
      '+7 (999) 000-00-01',
      '89990000001',
    ]) {
      expect(
        formatter.formatEditUpdate(_value(''), _value(input)).text,
        '(999) 000-00-01',
      );
    }
    expect(formatter.formatEditUpdate(_value(''), _value('abc')).text, isEmpty);
  });

  test('backspace and forward delete across every mask separator', () {
    const text = '(912) 345-67-89';
    for (final separator in [5, 9, 12]) {
      final digitIndex = _digits(text.substring(0, separator)).length;
      final after = text.replaceRange(separator, separator + 1, '');
      final backspace = formatter.formatEditUpdate(
        _value(text, separator + 1),
        _value(after, separator),
      );
      expect(
        _digits(backspace.text),
        '9123456789'.replaceRange(digitIndex - 1, digitIndex, ''),
      );
      expect(
        _digits(
          backspace.text.substring(0, backspace.selection.extentOffset),
        ).length,
        digitIndex - 1,
      );
      final delete = formatter.formatEditUpdate(
        _value(text, separator),
        _value(after, separator),
      );
      expect(
        _digits(delete.text),
        '9123456789'.replaceRange(digitIndex, digitIndex + 1, ''),
      );
      expect(
        _digits(delete.text.substring(0, delete.selection.extentOffset)).length,
        digitIndex,
      );
    }
  });

  test(
    'backspace removes a digit when iOS first removes a closing bracket',
    () {
      final deleted = formatter.formatEditUpdate(
        _value('(999)', 4),
        _value('(999', 4),
      );

      expect(deleted.text, '(99');
      expect(deleted.selection.extentOffset, deleted.text.length);
    },
  );

  test(
    'backspace through the closing bracket works with iOS cursor movement',
    () {
      final deleted = formatter.formatEditUpdate(
        _value('(999)', 5),
        _value('(999', 4),
      );

      expect(deleted.text, '(99');
      expect(deleted.selection.extentOffset, deleted.text.length);
    },
  );

  test(
    'middle edit preserves cursor and selected text can be replaced/cleared',
    () {
      final inserted = formatter.formatEditUpdate(
        _value('(912) 45', 6),
        _value('(912) 345', 7),
      );
      expect(inserted.text, '(912) 345');
      expect(inserted.selection.extentOffset, 7);
      final selected = TextEditingValue(
        text: '(912) 345-67-89',
        selection: const TextSelection(baseOffset: 6, extentOffset: 9),
      );
      final replaced = formatter.formatEditUpdate(
        selected,
        _value('(912) 0-67-89', 7),
      );
      expect(replaced.text, '(912) 067-89');
      expect(replaced.selection.extentOffset, 7);
      expect(formatter.formatEditUpdate(selected, _value('')).text, isEmpty);
    },
  );

  test('birth date input rejects impossible calendar dates', () {
    final today = DateTime(2026, 9, 14);

    expect(BirthDateInput.canAppendDigit('310', '2', now: today), isFalse);
    expect(BirthDateInput.canAppendDigit('2902202', '5', now: today), isFalse);
    expect(BirthDateInput.canAppendDigit('2902202', '4', now: today), isTrue);
    expect(BirthDateInput.canAppendDigit('1509202', '7', now: today), isFalse);
    expect(BirthDateInput.isCompleteValid('29022024', now: today), isTrue);
    expect(BirthDateInput.isCompleteValid('29022025', now: today), isFalse);
    expect(BirthDateInput.format('12041993'), '12.04.1993');
  });

  testWidgets('phone prefix is fixed and partial local input cannot submit', (
    tester,
  ) async {
    await _pumpLogin(tester);
    expect(find.text('+7 '), findsOneWidget);
    final phoneField = find.byKey(const ValueKey('patient.phone.input'));
    expect(
      tester.widget<TextField>(phoneField).enableInteractiveSelection,
      isTrue,
    );
    await tester.enterText(phoneField, '9990000001');
    await tester.pump();
    expect(
      tester.widget<TextField>(phoneField).controller!.text,
      '(999) 000-00-01',
    );
    await tester.enterText(phoneField, '');
    await tester.pump();
    expect(tester.widget<TextField>(phoneField).controller!.text, isEmpty);
    await _enterDigits(tester, 'patient.phone.input', '999000000');
    await tester.tap(find.byKey(const ValueKey('patient.consent.checkbox')));
    await tester.pump();
    await tester.tap(find.text('Получить код'));
    await tester.pumpAndSettle();
    expect(find.text('Введите номер телефона'), findsOneWidget);
    expect(find.text('Подтверждение номера'), findsNothing);
  });

  testWidgets('SMS uses native numeric input and accepts six digits', (
    tester,
  ) async {
    await _openSms(tester);
    expect(find.text('+7 '), findsNothing);
    final field = find.byKey(const ValueKey('patient.sms.input'));
    final smsField = tester.widget<TextField>(field);
    expect(smsField.keyboardType, TextInputType.number);
    expect(smsField.enableInteractiveSelection, isTrue);
    expect(smsField.autofillHints, contains(AutofillHints.oneTimeCode));
    await tester.enterText(field, '1234567');
    await tester.pump();
    expect(tester.widget<TextField>(field).controller!.text, '123456');
    await tester.enterText(field, '');
    await tester.pump();
    expect(tester.widget<TextField>(field).controller!.text, isEmpty);
    await _enterDigits(tester, 'patient.sms.input', '11111');
    await tester.tap(find.text('Продолжить'));
    await tester.pumpAndSettle();
    expect(find.text('Введите 6 цифр из SMS'), findsOneWidget);
    await _enterDigits(tester, 'patient.sms.input', '111111');
    expect(tester.widget<TextField>(field).controller!.text, '111111');
    await tester.tap(find.text('Продолжить'));
    await tester.pumpAndSettle();
    expect(find.text('Здравствуйте, Иван'), findsOneWidget);
  });
}

Future<void> _pumpLogin(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  await tester.pumpWidget(
    MaterialApp(theme: AppTheme.light, home: const PatientPhoneLoginScreen()),
  );
  await tester.pumpAndSettle();
}

Future<void> _openSms(WidgetTester tester) async {
  await _pumpLogin(tester);
  await _enterDigits(tester, 'patient.phone.input', '9990000001');
  await tester.tap(find.byKey(const ValueKey('patient.consent.checkbox')));
  await tester.pump();
  await tester.tap(find.text('Получить код'));
  await tester.pumpAndSettle();
  expect(find.text('Подтверждение номера'), findsOneWidget);
  expect(find.textContaining('+7 (999) 000-00-01'), findsOneWidget);
}

Future<void> _enterDigits(
  WidgetTester tester,
  String fieldKey,
  String digits,
) async {
  final field = find.byKey(ValueKey(fieldKey));
  await tester.enterText(field, digits);
  await tester.pumpAndSettle();
}
