A minimalistic and configurable number formatter to use with the `TextField` widget.

## Features
<div align="center">
  <img src="https://github.com/user-attachments/assets/67827e06-f82d-49b7-aea6-4c737e1fee58" height="300" />
</div>

This package provides `TextInputFormatter` that solves the most common formatting use cases with number inputs:
* Separating digit groups in an integral part of the decimal number.
* Controlling the maximum length of integral and decimal parts of the decimal number.
* Different input caret moving behavior in integral and decimal parts.
* Defaulting to the formatted zero if the whole number is deleted.
* Controlling the group separator symbol and decimal separator symbol.
* Easily accessing the underlying `double` value of the formatted `String`.

### Why use this instead of `intl`?

The [`intl`](https://pub.dev/packages/intl) package also provides the powerful `NumberFormat` class that handles formatting the numbers in the context of the given locale, but it is only intended to operate with static text, and incorporating it into the `TextField` widget might be a bit problematic and can lead to weird behavior.
</br>
The same is true for packages like [`money2`](https://pub.dev/packages/money2) and [`money_formatter`](https://pub.dev/packages/money_formatter).
</br>
This package intends to provide minimalistic, configurable, and convenient functionality that most clients will expect to see when interacting with number inputs.

## Be Aware

While this package mainly operates on `String` values it also provides access to the `double` value of the formatted decimal number as well as number parsing, so it is susceptible to the issues that are tied to Dart's standard `double` implementation as it is based on the IEEE 754 standard for floating-point arithmetic, which has a finite precision. As a result, some numbers cannot be represented exactly, leading to small rounding errors in calculations.

<b>But</b> you should be alright as long as the maximum precision of fractional digits needed for your case is under four digits. </br>
If not, or if you need to perform mathematical operations on decimals, then you should consider developing a custom solution using something in line with the [`decimal`](https://pub.dev/packages/decimal).

## Getting started

Add the dependency to your `pubspec.yaml` and run `flutter pub get`

```yaml
dependencies:
  amount_input_formatter: ^0.1.0
```

or run

```console
$ dart pub add amount_input_formatter
```

then add import in your code:

```dart
import 'package:amount_input_formatter/amount_input_formatter.dart';
```

## Usage

`AmmountInputFormatter` extends Flutter's `TextInputFormatter` so it can be easily integrated into `TextField` or `TextFormField` by adding it to the `inputFormatters` argument list.

```dart
TextField(
  inputFormatters: [AmountInputFormatter()],
),
```

But most likely you will need to extract the `double` value of the formatted number from the `TextField`. </br>
In this case save the `AmmountInputFormatter` instance somewhere, for example in the state of your widget.

```dart
class _ExampleWidgetState extends State<ExampleWidget> {
  final _formatter = AmountInputFormatter();
```

then pass the object to your `TextField` and access the `double` value with `_formatter.doubleValue` getter

```dart
TextField(   
  inputFormatters: [_formatter],
  onChanged: (text) {
    final double result = _formatter.doubleValue;
  },
),
```

Also, there might be a case when you need to dynamically update the value of the field with a new value from some external source.</br>
Unfortunately, it is not possible from the formatter instance alone.
You will need to add a `TextEditingController` instance to your `TextField` and use one of the provided methods to sync the TextField content with the formatted.

```dart
class _ExampleWidgetState extends State<ExampleWidget> {
  final _controller = TextEditingController();
  final _formatter = AmountInputFormatter();

  /// You can use [setNumber] method from formatter with the [attachedController] parameter
  /// to sync the [TextField] content with formatter
  void updateNumberValue(num number) {
    _formatter.setNumber(
      number,
      attachedController: _controller,
    );
  }

  /// Or set and format the text value with extension method [setAndFormatText]
  /// for [TextEditingController]
  void updateTextValue(String text) {
    _controller.setAndFormatText(
      text: text,
      formatter: _formatter,
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      inputFormatters: [_formatter],
    );
  }
}

```


## Full Example

```dart
class ExamplePage extends StatefulWidget {
  const ExamplePage({
    super.key,
  });

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  final _controller = TextEditingController();
  final _formatter = AmountInputFormatter(
    integralLength: 10,
    groupSeparator: ',',
    fractionalDigits: 3,
    decimalSeparator: '.',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Amount Input Formatter'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ListenableBuilder(
                listenable: _controller,
                builder: (
                    context,
                    child,
                    ) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Underlying double value: ${_formatter.doubleValue}',
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Formatted value: ${_formatter.formattedValue}',
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controller,
                inputFormatters: [_formatter],
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```
