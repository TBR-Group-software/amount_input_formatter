import 'package:amount_input_formatter/amount_input_formatter.dart';
import 'package:flutter/material.dart';

/// Extension on [TextEditingController] that provides methods to use in
/// conjunction with [AmountInputFormatter] class.
extension TextControllerExtension on TextEditingController {
  /// Formats and sets the current text of the [TextField] widget to which the
  /// called controller is attached.
  /// Returns the set text value.
  String setAndFormatText({
    required String text,
    required AmountInputFormatter formatter,
    TextEditingValue? oldValue,
  }) {
    value = formatter.formatEditUpdate(
      oldValue ?? value,
      TextEditingValue(text: text),
    );

    return this.text;
  }

  /// Syncs the controller [value] with current state of the formatter.
  /// Returns the synced text value.
  String syncWithFormatter({required AmountInputFormatter formatter}) {
    value = TextEditingValue(
      text: formatter.formattedValue,
      selection: TextSelection.collapsed(
        offset: formatter.formatter.indexOfDot,
      ),
    );

    return text;
  }
}
