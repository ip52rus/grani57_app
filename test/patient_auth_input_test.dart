import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grani57_app/core/design_system/theme/app_theme.dart';
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
        '999 000-00-01',
      );
    }
    expect(formatter.formatEditUpdate(_value(''), _value('abc')).text, isEmpty);
  });

  test('backspace and forward delete across every mask separator', () {
    const text = '912 345-67-89';
    for (final separator in [3, 7, 10]) {
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
    'middle edit preserves cursor and selected text can be replaced/cleared',
    () {
      final inserted = formatter.formatEditUpdate(
        _value('912 45', 4),
        _value('912 345', 5),
      );
      expect(inserted.text, '912 345');
      expect(inserted.selection.extentOffset, 5);
      final selected = TextEditingValue(
        text: '912 345-67-89',
        selection: const TextSelection(baseOffset: 4, extentOffset: 7),
      );
      final replaced = formatter.formatEditUpdate(
        selected,
        _value('912 0-67-89', 5),
      );
      expect(replaced.text, '912 067-89');
      expect(replaced.selection.extentOffset, 5);
      expect(formatter.formatEditUpdate(selected, _value('')).text, isEmpty);
    },
  );

  testWidgets('phone prefix is fixed and partial local input cannot submit', (
    tester,
  ) async {
    await _pumpLogin(tester);
    final controller = tester
        .widget<TextField>(find.byType(TextField))
        .controller!;
    expect(find.text('+7 (921) 000-00-00'), findsOneWidget);
    expect(find.text('999 000-00-01'), findsNothing);
    expect(controller.text, isEmpty);
    await tester.tap(find.byType(TextField));
    for (final digit in '9990000001'.split('')) {
      tester.testTextInput.updateEditingValue(_value(controller.text + digit));
      await tester.pump();
    }
    expect(controller.text, '999 000-00-01');
    for (var i = 0; i < 10; i++) {
      tester.testTextInput.updateEditingValue(
        _value(controller.text.substring(0, controller.text.length - 1)),
      );
      await tester.pump();
    }
    expect(controller.text, isEmpty);
    expect(find.text('+7 (921) 000-00-00'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '999000000');
    await tester.tap(find.text('Получить код'));
    await tester.pumpAndSettle();
    expect(find.text('Введите номер телефона'), findsOneWidget);
    expect(find.text('Подтверждение номера'), findsNothing);
  });

  testWidgets(
    'SMS accepts sixth digit, limits paste and typing, deletes to empty',
    (tester) async {
      await _openSms(tester);
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(
        field.inputFormatters!.whereType<RussianPhoneInputFormatter>(),
        isEmpty,
      );
      final controller = field.controller!;
      expect(controller.text, isEmpty);
      expect(find.text('+7 '), findsNothing);
      await tester.tap(find.byType(TextField));
      for (var i = 1; i <= 6; i++) {
        tester.testTextInput.updateEditingValue(_value('${controller.text}$i'));
        await tester.pump();
        expect(controller.text, '123456'.substring(0, i));
      }
      tester.testTextInput.updateEditingValue(_value('${controller.text}7'));
      await tester.pump();
      expect(controller.text, '123456');
      for (var i = 5; i >= 0; i--) {
        tester.testTextInput.updateEditingValue(
          _value(controller.text.substring(0, controller.text.length - 1)),
        );
        await tester.pump();
        expect(controller.text, '123456'.substring(0, i));
      }
      await tester.enterText(find.byType(TextField), 'a01 23-45678');
      expect(controller.text, '012345');
      await tester.enterText(find.byType(TextField), '11111');
      await tester.tap(find.text('Продолжить'));
      await tester.pumpAndSettle();
      expect(find.text('Введите 6 цифр из SMS'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '111111');
      expect(controller.text, '111111');
      await tester.tap(find.text('Продолжить'));
      await tester.pumpAndSettle();
      expect(find.text('Patient shell'), findsOneWidget);
    },
  );
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
  await tester.enterText(find.byType(TextField), '9990000001');
  await tester.tap(find.text('Получить код'));
  await tester.pumpAndSettle();
  expect(find.text('Подтверждение номера'), findsOneWidget);
  expect(find.textContaining('+7 999 000-00-01'), findsOneWidget);
}
