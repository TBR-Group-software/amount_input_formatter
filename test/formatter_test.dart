import 'package:amount_input_formatter/amount_input_formatter.dart';
import 'package:amount_input_formatter/src/amount_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'testing_widgets/text_field_widget.dart';

void main() {
  group(
    'A set of tests to check on formatter functionalities.',
    () {
      final formatter = AmountInputFormatter(
        initialValue: 1111112.11,
      );

      test(
        'Initially set a number value with the new value set.',
        () {
          expect(formatter.formattedValue, '1,111,112.110');
          expect(formatter.doubleValue, 1111112.11);

          formatter.setNumber(12456);
          expect(formatter.doubleValue, 12456);
          expect(formatter.formattedValue, '12,456.000');
        },
      );

      test(
        'Clear formatter and them set a number for the empty formatter.',
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
    'Initially set a value with no fractional digits, and edit afterwards.',
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
    'Initially, set a value; edit it with the decimal separator removal.',
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
    'Copy-paste with truncation of the longer decimal part.',
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

  group(
    'A set of tests on a widget with a TextField with a TextEditingController '
    'and an AmountInputFormatter attached.',
    () {
      testWidgets(
        'Test formatter with a TextField widget simulating user inputs with '
        'following steps:\n'
        '1. Copy-pasting the initial number to the TextField.\n'
        '2. Deleting one character in the middle of integral part.\n'
        '3. Deleting a decimal point after the integral part.',
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
        'TextEditingController attached to TextField.',
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

      testWidgets(
        'Emulation of "Delete" button behavior on Windows devices.',
        (tester) async {
          final controller = TextEditingController();
          final formatter = AmountInputFormatter(
            fractionalDigits: 2,
            groupedDigits: 5,
          );
          final textFieldPage = TextFieldWidget(
            formatter: formatter,
            controller: controller,
          );

          await tester.pumpWidget(textFieldPage);

          // Initially setting the value with enterText() method.
          // This one works like copy-pasting the whole value.
          await tester.enterText(find.byType(TextField), '4321.12');

          const formattingResult1 = '4321.12';
          expect(controller.text, formattingResult1);
          expect(find.text(formattingResult1), findsOneWidget);
          expect(formatter.doubleValue, 4321.12);

          controller.value = const TextEditingValue(
            text: '4321.12',
            selection: TextSelection.collapsed(offset: 0),
          );
          await tester.enterText(find.byType(TextField), '321.12');

          const formattingResult2 = '321.12';
          expect(controller.text, formattingResult2);
          expect(find.text(formattingResult2), findsOneWidget);
          expect(formatter.doubleValue, 321.12);

          controller.value = const TextEditingValue(
            text: '21.12',
            selection: TextSelection.collapsed(offset: 0),
          );
          await tester.enterText(find.byType(TextField), '1.12');

          const formattingResult3 = '1.12';
          expect(controller.text, formattingResult3);
          expect(find.text(formattingResult3), findsOneWidget);
          expect(formatter.doubleValue, 1.12);
          expect(controller.selection.baseOffset, 0);

          await tester.enterText(find.byType(TextField), '.12');

          const formattingResult4 = '0.12';
          expect(controller.text, formattingResult4);
          expect(find.text(formattingResult4), findsOneWidget);
          expect(formatter.doubleValue, 0.12);
          expect(controller.selection.baseOffset, 1);
        },
      );

      testWidgets(
        'Test for isEmptyAllowed formatter flag. Should enable blanking out '
        'the entire TextField content if true, if false - should set the text '
        'to formatted zero.',
        (tester) async {
          final controller = TextEditingController();
          final formatter = AmountInputFormatter(
            fractionalDigits: 2,
            groupSeparator: ' ',
            decimalSeparator: ',',
            isEmptyAllowed: true,
          );
          final textFieldPage = TextFieldWidget(
            formatter: formatter,
            controller: controller,
          );

          await tester.pumpWidget(textFieldPage);
          await tester.enterText(find.byType(TextField), '99999');

          const formattingResult1 = '99 999,00';
          expect(controller.text, formattingResult1);
          expect(find.text(formattingResult1), findsOneWidget);
          expect(formatter.doubleValue, 99999.0);

          await tester.enterText(find.byType(TextField), '');

          const formattingResult2 = '';
          expect(controller.text, formattingResult2);
          expect(find.text(formattingResult2), findsOneWidget);
          expect(formatter.doubleValue, 0);

          formatter.formatter.isEmptyAllowed = false;
          controller.syncWithFormatter(formatter: formatter);

          const formattingResult3 = '0,00';
          expect(controller.text, formattingResult3);
          expect(find.text(formattingResult3), findsOneWidget);
          expect(formatter.doubleValue, 0);
        },
      );
    },
  );
}
