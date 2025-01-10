import 'package:amount_input_formatter/amount_input_formatter.dart';
import 'package:flutter/material.dart';

class TextFieldWidget extends StatefulWidget {
  const TextFieldWidget({Key? key}) : super(key: key);

  @override
  State<TextFieldWidget> createState() => TextFieldWidgetState();
}

class TextFieldWidgetState extends State<TextFieldWidget> {
  final AmountInputFormatter formatter = AmountInputFormatter();
  final TextEditingController controller = TextEditingController();

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
