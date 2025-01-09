import 'package:flutter_test/flutter_test.dart';

import 'package:example/main.dart';

void main() {
  testWidgets(
    '',
    (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const AmountFormatterExampleApp());
    },
  );
}
