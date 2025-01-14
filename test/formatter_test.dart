import 'package:amount_input_formatter/amount_input_formatter.dart';
import 'package:amount_input_formatter/src/amount_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'text_field_widget.dart';

void main() {
  group(
    'A set of tests designed to emulate input behaviour',
    () {
      final formatter = AmountInputFormatter(
        initialValue: 1111112.11,
      );

      test(
        'Initially set number value with new value set',
        () {
          expect(formatter.formattedValue, '1,111,112.110');
          expect(formatter.doubleValue, 1111112.11);

          formatter.setNumber(12456);
          expect(formatter.doubleValue, 12456);
          expect(formatter.formattedValue, '12,456.000');
        },
      );

      test(
        'Set number for empty formatter',
        () {
          formatter
            ..clear()
            ..setNumber(222.2222);
          expect(formatter.doubleValue, 222.2222);
          expect(formatter.formattedValue, '222.222');
        },
      );
    },
  );

  test(
    'Initially set value with no fractional digits, and edit afterward',
    () {
      final formatter = AmountInputFormatter(
        initialValue: 89898999,
        fractionalDigits: 0,
      );

      const originalText = '89,898,999';
      expect(formatter.formattedValue, originalText);
      expect(formatter.doubleValue, 89898999);

      const newText = '89,898,99';
      formatter.formatEditUpdate(
        const TextEditingValue(
          text: originalText,
          selection: TextSelection.collapsed(offset: originalText.length),
        ),
        const TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        ),
      );
      expect(formatter.formattedValue, '8,989,899');
      expect(formatter.doubleValue, 8989899.0);
    },
  );

  test(
    'Initially set value; Edit with decimal separator removal',
    () {
      final formatter = AmountInputFormatter(
        initialValue: 12345.098767,
        fractionalDigits: 4,
        groupSeparator: ' ',
      );

      const originalText = '12 345.0987';
      expect(formatter.doubleValue, 12345.098767);
      expect(formatter.formattedValue, originalText);

      formatter.formatEditUpdate(
        const TextEditingValue(
          text: originalText,
          selection: TextSelection.collapsed(offset: 6),
        ),
        const TextEditingValue(
          text: '12 3450987',
          selection: TextSelection.collapsed(offset: 5),
        ),
      );
      expect(formatter.formattedValue, '12 345.0000');
      expect(formatter.doubleValue, 12345.0);
    },
  );

  test(
    'Copy-paste with truncation of the longer decimal part',
    () {
      final formatter = AmountInputFormatter(
        fractionalDigits: 6,
      )..formatEditUpdate(
          TextEditingValue.empty,
          const TextEditingValue(
            text: '123456789.987654321',
            selection: TextSelection.collapsed(offset: 11),
          ),
        );

      expect(formatter.formattedValue, '123,456,789.987654');
      expect(formatter.doubleValue, 123456789.987654);
    },
  );

  testWidgets(
    'Test formatter with a TextField widget simulating user inputs',
    (tester) async {
      final key = GlobalKey<TextFieldWidgetState>();
      final textFieldPage = TextFieldWidget(
        key: key,
      );

      await tester.pumpWidget(textFieldPage);

      await tester.enterText(find.byType(TextField), '123456789.123');

      const formattingResult1 = '123,456,789.123';
      expect(key.currentState?.controller.text, formattingResult1);
      expect(find.text(formattingResult1), findsOneWidget);
      expect(key.currentState?.formatter.doubleValue, 123456789.123);

      await tester.enterText(find.byType(TextField), '123,46,789.123');

      const formattingResult2 = '12,346,789.123';
      expect(key.currentState?.controller.text, formattingResult2);
      expect(find.text(formattingResult2), findsOneWidget);
      expect(key.currentState?.formatter.doubleValue, 12346789.123);

      await tester.enterText(find.byType(TextField), '12,346,789123');

      const formattingResult3 = '12,346,789.000';
      expect(key.currentState?.controller.text, formattingResult3);
      expect(find.text(formattingResult3), findsOneWidget);
      expect(key.currentState?.formatter.doubleValue, 12346789.0);
    },
  );

  testWidgets(
    'Set the initial value for the formatter and sync with '
    'TextEditingController attached to TextField',
    (tester) async {
      final key = GlobalKey<TextFieldWidgetState>();
      final textFieldPage = TextFieldWidget(
        key: key,
        initialValue: 12345.543,
      );

      await tester.pumpWidget(textFieldPage);

      const formattingResult1 = '12,345.543';
      expect(key.currentState?.controller.text, formattingResult1);
      expect(find.text(formattingResult1), findsOneWidget);
      expect(key.currentState?.formatter.doubleValue, 12345.543);

      await tester.enterText(find.byType(TextField), '12,3456.543');

      const formattingResult2 = '123,456.543';
      expect(key.currentState?.controller.text, formattingResult2);
      expect(find.text(formattingResult2), findsOneWidget);
      expect(key.currentState?.formatter.doubleValue, 123456.543);
    },
  );
}
