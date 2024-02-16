class NumberFormatter {
  /// Unicode "Left-To-Right Embedding" (LRE) character.
  static const lre = '\u202A';

  /// Unicode "Pop Directional Formatting" (PDF) character.
  static const pdf = '\u202C';

  /// Default thousands separator used by package.
  static const kComma = ',';

  /// Default decimal separator used by package. Also, used in number parsing.
  static const kDot = '.';

  static const kIntegralLengthLimit = 13;
  static const kEmptyValue = '';
  static const _kZeroValue = '0';

  /// [fractionalDigits] sets the inner [_ftlDigits]
  NumberFormatter._({
    required int lengthLimiter,
    required String thousandsSeparator,
    required String decimalSeparator,
    required int fractionalDigits,
    required String initialFormattedValue,
    double? initialValue,
  })  : _intLthLimiter = lengthLimiter,
        _thSeparator = thousandsSeparator,
        _dcSeparator = decimalSeparator,
        _ftlDigits = fractionalDigits,
        _formattedNum = initialFormattedValue,
        _numValue = initialValue;

  NumberFormatter.defaultSet()
      : _intLthLimiter = 13,
        _thSeparator = kComma,
        _dcSeparator = kDot,
        _ftlDigits = 2,
        _formattedNum = kEmptyValue;

  factory NumberFormatter({
    required int integralLengthLimiter,
    required String thousandsSeparator,
    required String decimalSeparator,
    required int fractionalDigits,
    num? initialValue,
  }) {
    initialValue = initialValue?.toDouble();
    late String initialFormattedValue;
    if (initialValue != null) {
      final doubleParts = initialValue.abs().toString().split(kDot);
      final nBuilder = StringBuffer(initialValue < 0 ? '-' : '');

      List<String> list = [];
      final integerPart = doubleParts.first;
      final thBuilder = StringBuffer();
      for (int i = integerPart.length - 1; i >= 0; i--) {
        thBuilder.write(integerPart[i]);
        if (thBuilder.length == 3) {
          list.add(
            String.fromCharCodes(thBuilder.toString().codeUnits.reversed),
          );
          thBuilder.clear();
        }
      }

      if (thBuilder.isNotEmpty) {
        list.add(String.fromCharCodes(thBuilder.toString().codeUnits.reversed));
      }
      nBuilder.writeAll(
        list.reversed,
        thousandsSeparator,
      );

      if (fractionalDigits > 0) {
        nBuilder.write(decimalSeparator);
        final decimalPart = doubleParts.last;
        if (decimalPart.length > fractionalDigits) {
          nBuilder.write(decimalPart.substring(0, fractionalDigits));
        } else {
          nBuilder.write(decimalPart);
          if (decimalPart.length < fractionalDigits) {
            for (int i = 0; i < fractionalDigits - decimalPart.length; i++) {
              nBuilder.write(_kZeroValue);
            }
          }
        }
      }
      initialFormattedValue = nBuilder.toString();
    } else {
      initialFormattedValue = kEmptyValue;
    }
    return NumberFormatter._(
      lengthLimiter: integralLengthLimiter,
      thousandsSeparator: thousandsSeparator,
      decimalSeparator: decimalSeparator,
      fractionalDigits: fractionalDigits,
      initialValue: initialValue?.toDouble(),
      initialFormattedValue: initialFormattedValue,
    );
  }

  final int _intLthLimiter;
  final String _thSeparator;
  final String _dcSeparator;
  final int _ftlDigits;
  String _formattedNum;
  double? _numValue;

  set doubleValue(num? number) => _processNumberValue(number);

  double? get doubleValue => _numValue;

  String get formattedValue => setTextValue(_formattedNum) ?? kEmptyValue;

  String get ltrEnforcedValue => '$lre$formattedValue$pdf';

  String? setTextValue(String textNumber) {
    textNumber = textNumber.replaceAll(_thSeparator, kEmptyValue);
    var doubleParts = textNumber.split(_dcSeparator);
    if (doubleParts.first.length > _intLthLimiter) return null;

    if (doubleParts.length == 1) doubleParts.add(kEmptyValue);
    final number = double.tryParse(
      '${doubleParts.first}$kDot${doubleParts.last}',
    );
    if (number == null) return null;

    _numValue = number;
    doubleParts = number.abs().toString().split(kDot);
    final builder = StringBuffer(number < 0 ? '-' : '');
    builder.writeAll(_processIntegerPart(doubleParts.first), _thSeparator);
    builder.write(_processDecimalPart(doubleParts.last));

    return _formattedNum = builder.toString();
  }

  String? setDoubleValue(num? number) => _processNumberValue(number);

  String? decimalPartEdit({
    required String textNumber,
    required int indexOfDot,
    required int baseOffset,
  }) =>
      _decimalPartEdit(
        textNumber,
        indexOfDot,
        baseOffset,
      );

  void clearFormatter() {
    _numValue = null;
    _formattedNum = kEmptyValue;
  }

  String _processNumberValue(num? number) {
    if (number == null) {
      _numValue = null;
      return _formattedNum = kEmptyValue;
    }

    number = _numValue = number.toDouble();
    final doubleParts = number.abs().toString().split(kDot);
    final builder = StringBuffer(number < 0 ? '-' : '');
    builder.writeAll(_processIntegerPart(doubleParts.first), _thSeparator);
    builder.write(_processDecimalPart(doubleParts.last));

    return _formattedNum = builder.toString();
  }

  Iterable<String> _processIntegerPart(String integerPart) {
    List<String> list = [];
    final builder = StringBuffer();
    for (int i = integerPart.length - 1; i >= 0; i--) {
      builder.write(integerPart[i]);
      if (builder.length == 3) {
        list.add(String.fromCharCodes(builder.toString().codeUnits.reversed));
        builder.clear();
      }
    }

    if (builder.isNotEmpty) {
      list.add(String.fromCharCodes(builder.toString().codeUnits.reversed));
    }
    return list.reversed;
  }

  String _processDecimalPart(String decimalPart) {
    if (_ftlDigits <= 0) return kEmptyValue;

    if (decimalPart.length > _ftlDigits) {
      return '$_dcSeparator${decimalPart.substring(0, _ftlDigits)}';
    } else if (decimalPart.length == _ftlDigits) {
      return '$_dcSeparator$decimalPart';
    }

    final builder = StringBuffer('$_dcSeparator$decimalPart');
    for (int i = 0; i < _ftlDigits - decimalPart.length; i++) {
      builder.write(_kZeroValue);
    }
    return builder.toString();
  }

  String? _decimalPartEdit(
    String textNumber,
    int indexOfDot,
    int baseOffset,
  ) {
    var textNum = textNumber;
    var indexOfDot = textNum.indexOf(_dcSeparator);

    if (indexOfDot < 0 && _formattedNum.contains(_dcSeparator)) {
      textNum = textNum.substring(0, baseOffset);
    }
    textNum = textNum.replaceAll(_thSeparator, kEmptyValue);
    var doubleParts = textNum.split(_dcSeparator);

    if (doubleParts.length == 1) doubleParts.add(kEmptyValue);
    if (doubleParts.last.length > _ftlDigits) return null;

    final number = double.tryParse(
      '${doubleParts.first}$kDot${doubleParts.last}',
    );
    if (number == null) return null;

    final decimalPart = doubleParts.last;
    doubleParts = number.abs().toString().split(kDot);
    _numValue = number;
    final builder = StringBuffer(number < 0 ? '-' : '');
    builder.writeAll(_processIntegerPart(doubleParts.first), _thSeparator);
    if (indexOfDot < 0) {
      builder.write(_processDecimalPart(doubleParts.last));
    } else {
      builder.write(_dcSeparator);
      builder.write(indexOfDot == textNumber.length - 1 ? '' : decimalPart);
    }

    return _formattedNum = builder.toString();
  }
}
