import 'package:amount_input_formatter/src/amount_input_formatter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final formatter1 = AmountInputFormatter(
    initialValue: 1111112.11,
    fractionalDigits: 3,
  );

  test(
    'Initial set number value with new value set',
    () {
      expect(formatter1.formattedValue, '1,111,112.110');
      expect(formatter1.doubleValue, 1111112.11);

      formatter1.setNumber(12456);
      expect(formatter1.doubleValue, 12456);
      expect(formatter1.formattedValue, '12,456.000');
    },
  );

  final formatter2 = AmountInputFormatter();
  test(
    'Set number for empty formatter',
    () {
      formatter2.setNumber(222.2222);
      expect(formatter2.doubleValue, 222.2222);
      expect(formatter2.formattedValue, '222.22');
    },
  );

  final formatter3 = AmountInputFormatter(
    initialValue: 89898999,
    fractionalDigits: 0,
  );
  test(
    'Initial set value with no fractional digits, and edit afterward',
    () {
      const originalText = '89,898,999';
      expect(formatter3.formattedValue, originalText);
      expect(formatter3.doubleValue, 89898999);

      const newText = '8,989,899';
      formatter3.formatEditUpdate(
        const TextEditingValue(
          text: originalText,
          selection: TextSelection.collapsed(offset: originalText.length),
        ),
        const TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        ),
      );
      expect(formatter3.formattedValue, newText);
      expect(formatter3.doubleValue, 8989899);
    },
  );

  final formatter4 = AmountInputFormatter(
    initialValue: 12345.098767,
    fractionalDigits: 4,
    thousandsSeparator: ' '
  );
  test(
    'Initial set value, edit with decimal separator removal',
        () {
      const originalText = '12 345.0987';
      expect(formatter4.doubleValue, 12345.098767);
      expect(formatter4.formattedValue, originalText);

      const newText = '12 3450987';
      formatter4.formatEditUpdate(
        const TextEditingValue(
          text: originalText,
          selection: TextSelection.collapsed(offset: 7),
        ),
        const TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: 6),
        ),
      );
      expect(formatter4.formattedValue, '12 345.0000');
      expect(formatter4.doubleValue, 12345.0);
    },
  );
}
