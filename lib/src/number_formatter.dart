/// A minimalistic and configurable Number Formatter.
class NumberFormatter {
  /// The default [NumberFormatter] factory.
  /// [integralLengthLimiter] - sets the limit to length of integral part of
  /// the number. For example here: 11111.222 it will be the 11111
  /// part before the dot.
  /// Defaults to 24.
  /// [integralPartSeparator] - sets the "thousands" separator symbol that
  /// should separate an integral part of the number into chunks after a
  /// certain number of characters.
  /// Defaults to ','.
  /// [decimalSeparator] - sets the separator symbol that seats between the
  /// integral and decimal parts of the number. Typically it's a '.' or an ','
  /// depending on the language.
  /// Defaults to '.'.
  /// [intSeparatedDigitsCount] - The number of digits that should be grouped in
  /// an integral part of the number before separation. Setting it, for example,
  /// to 3 for the number 12345.123 will result in the following formatting:
  /// 12,345.123.
  /// Defaults to 3.
  /// [fractionalDigits] - will limit the number of digits after the decimal
  /// separator.
  /// Defaults to 3.
  /// [initialValue] - the initial numerical value that is supplied to the
  /// formatter and will be processed.
  factory NumberFormatter({
    int integralLengthLimiter = kIntegralLengthLimit,
    String integralPartSeparator = kComma,
    String decimalSeparator = kDot,
    int fractionalDigits = 3,
    int intSeparatedDigitsCount = 3,
    num? initialValue,
  }) {
    if (initialValue == null) {
      return NumberFormatter._(
        lengthLimiter: integralLengthLimiter,
        integralPartSeparator: integralPartSeparator,
        intSeparatedDigitsCount: intSeparatedDigitsCount,
        decimalSeparator: decimalSeparator,
        fractionalDigits: fractionalDigits,
        initialValue: 0,
        indexOfDot: -1,
        initialFormattedValue: kEmptyValue,
      );
    }

    final doubleParts = initialValue.toDouble().abs().toString().split(kDot);
    final formattedInteger = '${initialValue < 0 ? '-' : ''}'
        '${_processIntegerPart(
      integerPart: doubleParts.first,
      thSeparator: integralPartSeparator,
      intSpDigits: intSeparatedDigitsCount,
    )}';

    return NumberFormatter._(
      lengthLimiter: integralLengthLimiter,
      integralPartSeparator: integralPartSeparator,
      intSeparatedDigitsCount: intSeparatedDigitsCount,
      decimalSeparator: decimalSeparator,
      fractionalDigits: fractionalDigits,
      initialValue: initialValue.toDouble(),
      initialFormattedValue: '$formattedInteger${_processDecimalPart(
        decimalPart: doubleParts.last,
        ftlDigits: fractionalDigits,
        dcSeparator: decimalSeparator,
      )}',
      indexOfDot: formattedInteger.length,
    );
  }

  /// [fractionalDigits] sets the inner [ftlDigits]
  NumberFormatter._({
    required int lengthLimiter,
    required String integralPartSeparator,
    required String decimalSeparator,
    required int fractionalDigits,
    required String initialFormattedValue,
    required double? initialValue,
    required int intSeparatedDigitsCount,
    required int indexOfDot,
  })  : intLthLimiter = lengthLimiter,
        intSeparator = integralPartSeparator,
        intSpDigits = intSeparatedDigitsCount,
        dcSeparator = decimalSeparator,
        ftlDigits = fractionalDigits,
        _formattedNum = initialFormattedValue,
        _numPattern = RegExp('[^0-9$decimalSeparator]'),
        _doubleValue = initialValue ?? 0,
        _indexOfDot = indexOfDot;

  /// Default setting options for the formatter.
  NumberFormatter.defaultSettings()
      : intLthLimiter = kIntegralLengthLimit,
        intSeparator = kComma,
        dcSeparator = kDot,
        ftlDigits = 3,
        intSpDigits = 3,
        _formattedNum = kEmptyValue,
        _doubleValue = 0,
        _indexOfDot = -1,
        _numPattern = RegExp('[^0-9$kDot]');

  /// Unicode "Left-To-Right Embedding" (LRE) character \u202A.
  static const lre = '\u202A';

  /// Unicode "Pop Directional Formatting" (PDF) character \u202C.
  static const pdf = '\u202C';

  /// Default thousands separator used by package.
  static const kComma = ',';

  /// Default decimal separator used by package.
  static const kDot = '.';

  /// Default length limit of the integral part of the double number.
  static const kIntegralLengthLimit = 24;

  /// Default empty String value.
  static const kEmptyValue = '';

  /// Default value of the number placeholder.
  static const kZeroValue = '0';

  /// The length limit of the integral part of the double number.
  int intLthLimiter;

  /// A separator that should be used to split thousands in integral
  /// part of the number.
  String intSeparator;

  /// The number of digits that should be repeatedly separated in an integral
  /// part of the number.
  int intSpDigits;

  /// A separator that should be used to split decimal number at the
  /// floating point.
  String dcSeparator;

  /// The length of the fractional part of the decimal number.
  int ftlDigits;

  String _formattedNum;
  RegExp _numPattern;
  double _doubleValue;
  int _indexOfDot;

  /// Getter for the underlying decimal number, returns 0 in case of
  /// empty String value.
  double get doubleValue => _doubleValue;

  /// The current index of the symbol that separates the integral and decimal
  /// parts of the double value in formatted string.
  int get indexOfDot => _indexOfDot;

  /// Getter for the formatted String representation of the number.
  String get formattedNum => _formattedNum;

  /// Wraps the formatted string of the number with Unicode
  /// "Left-To-Right Embedding" (LRE) and "Pop Directional Formatting" (PDF)
  /// characters to force the formatted-string-number to be correctly displayed
  /// left-to-right inside of the otherwise RTL context
  String get ltrEnforcedValue => '$lre$formattedNum$pdf';

  /// This method should be used to process the integral part of the
  /// double number.
  /// It will iterate on the integral part from right to left and write each
  /// character into buffer separating the integral part after [intSpDigits]
  /// number of characters.
  static String _processIntegerPart({
    required String integerPart,
    required String thSeparator,
    required int intSpDigits,
  }) {
    final intBuffer = StringBuffer();
    for (var i = 1; i <= integerPart.length; i++) {
      intBuffer.write(integerPart[integerPart.length - i]);

      if (i % intSpDigits == 0 && i != integerPart.length) {
        intBuffer.write(thSeparator);
      }
    }

    // As the writes to buffer was made in reversed order it should
    // be reversed back.
    return String.fromCharCodes(intBuffer.toString().codeUnits.reversed);
  }

  /// This method should be used to process the decimal part of the
  /// double number.
  /// It will iterate on the decimal part from left to right and truncate it or
  /// add '0' until the number of characters is equal to [ftlDigits]
  static String _processDecimalPart({
    required String decimalPart,
    required int ftlDigits,
    required String dcSeparator,
  }) {
    if (ftlDigits <= 0) return kEmptyValue;
    print('HERE');

    if (decimalPart.length > ftlDigits) {
      print('HERE1');
      return '$dcSeparator${decimalPart.substring(0, ftlDigits)}';
    } else if (decimalPart.length == ftlDigits) {
      print('HERE2');
      return '$dcSeparator$decimalPart';
    }

    print('HERE3: $decimalPart');
    final builder = StringBuffer('$dcSeparator$decimalPart');
    for (var i = 0; i < ftlDigits - decimalPart.length; i++) {
      builder.write(kZeroValue);
    }
    return builder.toString();
  }

  String _processNumberValue(double? inputNumber) {
    print(inputNumber);
    if (inputNumber == null) {
      _doubleValue = 0;
      return _formattedNum = kEmptyValue;
    }

    _doubleValue = inputNumber;
    final doubleParts = inputNumber.abs().toString().split(kDot);

    final integerPart = '${inputNumber < 0 ? '-' : ''}${_processIntegerPart(
      integerPart: doubleParts.first,
      thSeparator: intSeparator,
      intSpDigits: intSpDigits,
    )}';

    // Set the index of dot to the length of the integral part of the number.
    _indexOfDot = integerPart.length;
    return _formattedNum = '$integerPart${_processDecimalPart(
      decimalPart: doubleParts.last,
      ftlDigits: ftlDigits,
      dcSeparator: dcSeparator,
    )}';
  }

  /// This method should be used to process the text input.
  /// It'll remove all unallowed characters from the string and try to convert
  /// it to the double value.
  String? processTextValue({
    required String textInput,
    required int baseOffset,
  }) {
    if (ftlDigits > 0) {
      final indexOfDot = textInput.indexOf(dcSeparator);

      if (indexOfDot < 0) {
        textInput = textInput.substring(0, baseOffset);
      }
    }
    print(textInput);

    final doubleParts = textInput
        .replaceAll(
          _numPattern,
          kEmptyValue,
        )
        .split(dcSeparator);
    print(doubleParts);

    if (doubleParts.first.length > intLthLimiter) return null;

    if (doubleParts.length == 1) doubleParts.add(kEmptyValue);
    print(double.parse('${doubleParts.first}$kDot${doubleParts.last}'));
    print(double.tryParse('${doubleParts.first}$kDot${doubleParts.last}'));

    return _processNumberValue(
      double.tryParse(
        '${doubleParts.first}$kDot${doubleParts.last}',
      ),
    );
  }

  /// This method will process and format the given numerical value through the
  /// formatter.
  /// Returns the formatted string representation of the number.
  String setNumValue(num number) => _processNumberValue(number.toDouble());

  /// Clears Formatter data by:
  /// Setting the formatted value to empty sting;
  /// Setting the double value to 0;
  /// Setting the index of the decimal floating point to -1.
  /// Formatter settings will remain unchanged.
  String clear() {
    _doubleValue = 0;
    _indexOfDot = -1;
    return _formattedNum = kEmptyValue;
  }
}
