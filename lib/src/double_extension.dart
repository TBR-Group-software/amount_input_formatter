import 'dart:math';

extension DoubleExtension on double {
  double truncateTo(int fractionDigits) =>
      (this * pow(10, fractionDigits)).truncate() / pow(10, fractionDigits);
}
