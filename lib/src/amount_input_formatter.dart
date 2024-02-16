import 'package:amount_input_formatter/src/number_formatter.dart';
import 'package:flutter/services.dart';

class AmountInputFormatter extends TextInputFormatter {
  AmountInputFormatter._({
    required NumberFormatter formatter,
    required String decimalSeparator,
    required int fractionalDigits,
  })  : _formatter = formatter,
        _dcSeparator = decimalSeparator,
        _ftlDigits = fractionalDigits,
        _emptyValue = NumberFormatter.kEmptyValue;

  factory AmountInputFormatter({
    int integralLengthLimiter = 13,
    String thousandsSeparator = NumberFormatter.kComma,
    String decimalSeparator = NumberFormatter.kDot,
    int fractionalDigits = 2,
    double? initialValue,
  }) {
    return AmountInputFormatter._(
      decimalSeparator: decimalSeparator,
      fractionalDigits: fractionalDigits,
      formatter: NumberFormatter(
        integralLengthLimiter: integralLengthLimiter,
        initialValue: initialValue,
        thousandsSeparator: thousandsSeparator,
        decimalSeparator: decimalSeparator,
        fractionalDigits: fractionalDigits,
      ),
    );
  }

  final NumberFormatter _formatter;
  final String _dcSeparator;
  final int _ftlDigits;
  final String _emptyValue;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    } else if (oldValue.text.isEmpty && newValue.text.length == 1) {
      return _processInputStart(oldValue, newValue);
    } else if (_isEditingDecimalPart(oldValue, newValue)) {
      return _processDecimalEditing(oldValue, newValue);
    } else if (newValue.text.length <= 4) {
      return _processShortInput(oldValue, newValue);
    }

    return _processEditing(oldValue, newValue);
  }

  double? get doubleValue => _formatter.doubleValue;

  String get formattedValue => _formatter.formattedValue;

  String get ltrEnforcedValue => _formatter.ltrEnforcedValue;

  void clearFormatting() => _formatter.clearFormatter();

  String setNumber(num? number) =>
      _formatter.setDoubleValue(number) ?? _emptyValue;

  TextEditingValue _processInputStart(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text == '-') return newValue;

    final newText = _formatter.setTextValue(newValue.text);
    if (newText == null) {
      return newValue.copyWith(
        text: _emptyValue,
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    return newValue.copyWith(
      text: newText,
      selection: const TextSelection.collapsed(offset: 1),
    );
  }

  TextEditingValue _processShortInput(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String? textNum = newValue.text;
    if (textNum.isEmpty) {
      _formatter.clearFormatter();
      return newValue;
    } else if (newValue.selection.baseOffset == 0 &&
        textNum[0] == _dcSeparator) {
      textNum = '0${newValue.text}';
    }

    textNum = _formatter.setTextValue(textNum);
    if (textNum == null) return oldValue;
    final value = _formatter.doubleValue ?? 0;
    if (value == 0) {
      _formatter.clearFormatter();
      return newValue.copyWith(
        text: _emptyValue,
        selection: const TextSelection.collapsed(offset: 0),
      );
    }
    return newValue.copyWith(
      text: textNum,
      selection: value < 1 && value > -1
          ? TextSelection.collapsed(offset: textNum.length)
          : newValue.selection,
    );
  }

  TextEditingValue _processDecimalEditing(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final indexOfDot = newValue.text.indexOf(_dcSeparator);
    final textNum = _formatter.decimalPartEdit(
      textNumber: newValue.text,
      baseOffset: newValue.selection.baseOffset,
      indexOfDot: indexOfDot,
    );
    if (textNum == null) return oldValue;
    return newValue.copyWith(
      text: textNum,
      selection: TextSelection.collapsed(
        offset:
            indexOfDot < 0 ? textNum.length - (_ftlDigits + 1) : textNum.length,
      ),
    );
  }

  TextEditingValue _processEditing(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = _formatter.setTextValue(newValue.text);
    if (newText == null) return oldValue;
    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(
        offset: _calculateOffset(oldValue, newText),
      ),
    );
  }

  int _calculateOffset(
    TextEditingValue oldValue,
    String newText,
  ) {
    var offset = 0;
    if (oldValue.selection.baseOffset == oldValue.text.length &&
        oldValue.text.length == newText.length) {
      return newText.length;
    } else if (newText.length < oldValue.text.length) {
      offset = oldValue.text.length - newText.length > 1
          ? oldValue.selection.extentOffset -
              (oldValue.text.length - newText.length)
          : oldValue.selection.extentOffset - 1;
      return offset < 0 ? 0 : offset;
    } else {
      offset = newText.length - oldValue.text.length > 1
          ? oldValue.selection.baseOffset +
              (newText.length - oldValue.text.length)
          : oldValue.selection.baseOffset + 1;
      return offset > newText.length ? newText.length - 1 : offset;
    }
  }

  bool _isEditingDecimalPart(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) =>
      _ftlDigits > 0 &&
      oldValue.selection.extentOffset >= oldValue.text.length - _ftlDigits &&
      oldValue.selection.extentOffset >= oldValue.selection.baseOffset;
}
