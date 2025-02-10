/// A minimalistic and configurable Number Formatter.
class NumberFormatter {
  /// The default [NumberFormatter] factory.
  /// [integralLength] - sets the limit to length of integral part of
  /// the number. For example here: 11111.222 it will be the 11111
  /// part before the dot.
  /// Defaults to 24.
  /// [groupSeparator] - sets the "thousands" separator symbol that
  /// should separate an integral part of the number into chunks after a
  /// certain number of characters.
  /// Defaults to ','.
  /// [decimalSeparator] - sets the separator symbol that seats between the
  /// integral and decimal parts of the number. Typically it's a '.' or an ','
  /// depending on the language.
  /// Defaults to '.'.
  /// [groupedDigits] - The number of digits that should be grouped in
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
    int integralLength = kIntegralLengthLimit,
    String groupSeparator = kComma,
    String decimalSeparator = kDot,
    int fractionalDigits = 3,
    int groupedDigits = 3,
    bool isEmptyAllowed = false,
    num? initialValue,
  }) {
    if (initialValue == null) {
      return NumberFormatter._(
        integralLength: integralLength,
        groupSeparator: groupSeparator,
        groupedDigits: groupedDigits,
        decimalSeparator: decimalSeparator,
        fractionalDigits: fractionalDigits,
        initialValue: 0,
        indexOfDot: -1,
        initialFormattedValue: kEmptyValue,
        isEmptyAllowed: isEmptyAllowed,
      );
    }

    final doubleParts = initialValue.toDouble().abs().toString().split(kDot);

    return NumberFormatter._(
      integralLength: integralLength,
      groupSeparator: groupSeparator,
      groupedDigits: groupedDigits,
      decimalSeparator: decimalSeparator,
      fractionalDigits: fractionalDigits,
      initialValue: initialValue.toDouble(),
      isEmptyAllowed: isEmptyAllowed,
      initialFormattedValue: '${_processIntegerPart(
        integerPart: doubleParts.first,
        thSeparator: groupSeparator,
        intSpDigits: groupedDigits,
      )}'
          '${_processDecimalPart(
        decimalPart: doubleParts.last,
        ftlDigits: fractionalDigits,
        dcSeparator: decimalSeparator,
      )}',
      indexOfDot: doubleParts.first.length,
    );
  }

  /// [fractionalDigits] sets the inner [ftlDigits]
  NumberFormatter._({
    required int integralLength,
    required String groupSeparator,
    required String decimalSeparator,
    required int fractionalDigits,
    required String initialFormattedValue,
    required double? initialValue,
    required int groupedDigits,
    required int indexOfDot,
    required bool isEmptyAllowed,
  })  : _isEmptyAllowed = isEmptyAllowed,
        _intLthLimiter = integralLength,
        _intSeparator = groupSeparator,
        _intSpDigits = groupedDigits,
        _dcSeparator = decimalSeparator,
        _ftlDigits = fractionalDigits,
        _formattedNum = initialFormattedValue,
        _numPattern = RegExp('[^0-9$decimalSeparator]'),
        _currentValue = initialValue ?? 0,
        _indexOfDot = indexOfDot;

  /// Default setting options for the formatter.
  NumberFormatter.defaultSettings()
      : _intLthLimiter = kIntegralLengthLimit,
        _intSeparator = kComma,
        _dcSeparator = kDot,
        _ftlDigits = 3,
        _intSpDigits = 3,
        _formattedNum = kEmptyValue,
        _currentValue = 0,
        _indexOfDot = -1,
        _numPattern = RegExp('[^0-9$kDot]'),
        _isEmptyAllowed = false;

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

  /// Default value '0' of the number placeholder.
  static const kZeroValue = '0';

  /// The length limit of the integral part of the double number.
  int _intLthLimiter;

  /// A separator that should be used to split thousands in integral
  /// part of the number.
  String _intSeparator;

  /// The number of digits that should be repeatedly separated in an integral
  /// part of the number.
  int _intSpDigits;

  /// A separator that should be used to split decimal number at the
  /// floating point.
  String _dcSeparator;

  /// The length of the fractional part of the decimal number.
  int _ftlDigits;

  /// Determines if the empty string is allowed for this formatter, or if
  /// the empty value should be a formatted zero.
  bool _isEmptyAllowed;

  String _formattedNum;
  RegExp _numPattern;
  double _currentValue;
  int _indexOfDot;
  double _previousValue = 0;

  /// The length limit of the integral part of the double number.
  int get intLthLimiter => _intLthLimiter;

  /// A separator that should be used to split thousands in integral
  /// part of the number.
  String get intSeparator => _intSeparator;

  /// The number of digits that should be repeatedly separated in an integral
  /// part of the number.
  int get intSpDigits => _intSpDigits;

  /// A separator that should be used to split decimal number at the
  /// floating point.
  String get dcSeparator => _dcSeparator;

  /// The length of the fractional part of the decimal number.
  int get ftlDigits => _ftlDigits;

  /// Getter for the underlying decimal number, returns 0 in case of
  /// empty String value.
  double get doubleValue => _doubleValue;

  /// Getter for retrieving the double value one input before the current one.
  /// In case there was no previous inputs returns 0.
  double get previousValue => _previousValue;

  /// The current index of the symbol that separates the integral and decimal
  /// parts of the double value in formatted string.
  int get indexOfDot => _indexOfDot;

  /// Getter for the formatted String representation of the number.
  String get formattedValue => _formattedNum;

  /// Determines if the empty string is allowed for this formatter, or if
  /// the empty value should be a formatted zero.
  bool get isEmptyAllowed => _isEmptyAllowed;

  /// Private getter for the current double value of the formatter.
  double get _doubleValue => _currentValue;

  /// Wraps the formatted string of the number with Unicode
  /// "Left-To-Right Embedding" (LRE) and "Pop Directional Formatting" (PDF)
  /// characters to force the formatted-string-number to be correctly displayed
  /// left-to-right inside of the otherwise RTL context
  String get ltrEnforcedValue => '$lre$formattedValue$pdf';

  /// The length limit of the integral part of the double number.
  set intLthLimiter(int value) {
    _intLthLimiter = value;

    processTextValue(textInput: _formattedNum);
  }

  /// A separator that should be used to split thousands in integral
  /// part of the number.
  set intSeparator(String value) {
    _intSeparator = value;

    processTextValue(textInput: _formattedNum);
  }

  /// The number of digits that should be repeatedly separated in an integral
  /// part of the number.
  set intSpDigits(int value) {
    _intSpDigits = value;

    processTextValue(textInput: _formattedNum);
  }

  /// A separator that should be used to split decimal number at the
  /// floating point.
  set dcSeparator(String value) {
    _dcSeparator = value;

    processTextValue(textInput: _formattedNum);
  }

  /// The length of the fractional part of the decimal number.
  set ftlDigits(int value) {
    _ftlDigits = value;

    processTextValue(textInput: _formattedNum);
  }

  /// Determines if the empty string is allowed for this formatter, or if
  /// the empty value should be a formatted zero.
  set isEmptyAllowed(bool value) {
    _isEmptyAllowed = value;

    processTextValue(textInput: _formattedNum);
  }

  /// Setter for the current double value of the formatter.
  /// Saves the current value of the formatter to the [_previousValue] variable
  /// before replacing it with a new one.
  set _doubleValue(double value) {
    _previousValue = _currentValue;
    _currentValue = value;
  }

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
    if (integerPart.length < intSpDigits) return integerPart;

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

    if (decimalPart.length > ftlDigits) {
      return '$dcSeparator${decimalPart.substring(0, ftlDigits)}';
    } else if (decimalPart.length == ftlDigits) {
      return '$dcSeparator$decimalPart';
    }

    return '$dcSeparator$decimalPart'
        '${kZeroValue * (ftlDigits - decimalPart.length)}';
  }

  String _processNumberValue({
    double? inputNumber,
    List<String>? doubleParts,
  }) {
    if (inputNumber == null) {
      _doubleValue = 0;
      return _formattedNum = kEmptyValue;
    }

    _doubleValue = inputNumber;
    doubleParts ??= inputNumber.abs().toString().split(kDot);

    // Set the index of dot to the length of the integral part of the number.
    _indexOfDot = doubleParts.first.length;

    return _formattedNum = '${_processIntegerPart(
      integerPart: doubleParts.first,
      thSeparator: intSeparator,
      intSpDigits: intSpDigits,
    )}'
        '${_processDecimalPart(
      decimalPart: doubleParts.last,
      ftlDigits: ftlDigits,
      dcSeparator: dcSeparator,
    )}';
  }

  String _processEmptyValue({
    required String textInput,
    required bool isEmptyAllowed,
  }) {
    _doubleValue = 0;

    if (isEmptyAllowed) {
      _indexOfDot = -1;
      return _formattedNum = kEmptyValue;
    }

    _indexOfDot = 1;
    return _formattedNum = '$kZeroValue'
        '${_ftlDigits > 0 ? _dcSeparator : ''}'
        '${kZeroValue * _ftlDigits}';
  }

  /// This method should be used to process the text input.
  /// It'll remove all unallowed characters from the string and try to convert
  /// it to the double value.
  String? processTextValue({
    required String textInput,
  }) {
    // Case when text input is deleted completely or is initially empty.
    if (textInput.isEmpty) {
      return _processEmptyValue(
        textInput: textInput,
        isEmptyAllowed: isEmptyAllowed,
      );
    }

    final doubleParts = textInput
        .replaceAll(
          _numPattern,
          kEmptyValue,
        )
        .split(dcSeparator);

    // In case if there is no decimal part in the provided string
    // representation of number.
    if (doubleParts.length == 1) {
      doubleParts.add(kEmptyValue);

      // It might be the case that the user deleted the decimal point or part of
      // the input with a decimal point was deleted with the selection range.
      // In this case, the decimal part should be zeroed.
      if (ftlDigits > 0 &&
          _indexOfDot > 0 &&
          _indexOfDot < doubleParts.first.length) {
        doubleParts.first = doubleParts.first.substring(0, _indexOfDot);
      }
    } else if (doubleParts.last.length > ftlDigits) {
      doubleParts.last = doubleParts.last.substring(0, ftlDigits);
    }

    // In case if integral part is longer than allowed abort the formatting.
    if (doubleParts.first.length > intLthLimiter) return null;

    // Checks if the integer part is empty, and sets the value to '0' if true.
    if (doubleParts.first.isEmpty) {
      doubleParts.first = kZeroValue;
    } else if (doubleParts.first[0] == kZeroValue &&
        doubleParts.first.length > 1) {
      var index = -1;

      for (var i = 0; i < doubleParts.first.length; i++) {
        if (doubleParts.first[i] != kZeroValue) break;

        index = i;
      }

      if (index == doubleParts.first.length - 1) index -= 1;

      if (index >= 0) {
        doubleParts.first = doubleParts.first.substring(index + 1);
      }
    }

    return _processNumberValue(
      inputNumber: double.tryParse(
        '${doubleParts.first}$kDot${doubleParts.last}',
      ),
      doubleParts: doubleParts,
    );
  }

  /// This method will process and format the given numerical value through the
  /// formatter.
  /// Returns the formatted string representation of the number.
  String setNumValue(num number) => _processNumberValue(
        inputNumber: number.toDouble(),
      );

  /// Clears Formatter data by:
  /// Setting the formatted value to empty sting;
  /// Setting the double value to 0;
  /// Setting the index of the decimal floating point to -1.
  /// Formatter settings will remain unchanged.
  String clear() {
    return _processEmptyValue(
      textInput: '',
      isEmptyAllowed: true,
    );
  }
}
