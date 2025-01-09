import 'package:amount_input_formatter/src/amount_input_formatter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'A set of test designed to emulate input behaviour',
    () {
      late AmountInputFormatter formatter;
      setUp(() {
        formatter = AmountInputFormatter(
          initialValue: 1111112.11,
        );
      });
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
        integralPartSeparator: ' ',
      );

      const originalText = '12 345.0987';
      expect(formatter.doubleValue, 12345.098767);
      expect(formatter.formattedValue, originalText);

      formatter.formatEditUpdate(
        const TextEditingValue(
          text: originalText,
          selection: TextSelection.collapsed(offset: 7),
        ),
        const TextEditingValue(
          text: '12 3450987',
          selection: TextSelection.collapsed(offset: 6),
        ),
      );
      expect(formatter.formattedValue, '12 345.0000');
      expect(formatter.doubleValue, 12345.0);
    },
  );

  test(
    'Test the amount input with the long integral and decimal parts',
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
}
