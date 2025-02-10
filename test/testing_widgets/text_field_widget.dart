import 'package:amount_input_formatter/amount_input_formatter.dart';
import 'package:flutter/material.dart';

class TextFieldWidget extends StatefulWidget {
  const TextFieldWidget({
    Key? key,
    this.initialValue,
    this.controller,
    this.formatter,
  }) : super(key: key);

  final num? initialValue;
  final TextEditingController? controller;
  final AmountInputFormatter? formatter;

  @override
  State<TextFieldWidget> createState() => TextFieldWidgetState();
}

class TextFieldWidgetState extends State<TextFieldWidget> {
  late final AmountInputFormatter formatter =
      widget.formatter ?? AmountInputFormatter();
  late final TextEditingController controller =
      widget.controller ?? TextEditingController();

  @override
  void initState() {
    super.initState();

    final initialValue = widget.initialValue;
    if (initialValue != null) {
      formatter.setNumber(
        initialValue,
        attachedController: controller,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: TextField(
            controller: controller,
            inputFormatters: [formatter],
          ),
        ),
      ),
    );
  }
}
