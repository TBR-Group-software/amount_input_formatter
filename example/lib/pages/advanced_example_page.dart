import 'dart:developer';

import 'package:amount_input_formatter/amount_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AdvancedExamplePage extends StatefulWidget {
  const AdvancedExamplePage({super.key});

  @override
  State<AdvancedExamplePage> createState() => _AdvancedExamplePageState();
}

class _AdvancedExamplePageState extends State<AdvancedExamplePage> {
  final AmountInputFormatter _formatter = AmountInputFormatter(
    initialValue: 1234567890.0987654321,
    fractionalDigits: 4,
  );
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    _controller.syncWithFormatter(formatter: _formatter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Advanced Example'),
      ),
      body: ListView(
        primary: false,
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          ControlsRowWidget(
            label1: 'Decimal separator: ',
            label2: 'Group separator: ',
            initialValue1: _formatter.formatter.dcSeparator,
            formatters1: [LengthLimitingTextInputFormatter(1)],
            onChanged1: (text) {
              _formatter.formatter.dcSeparator = text.isEmpty ? '.' : text;

              _controller.syncWithFormatter(formatter: _formatter);
            },
            initialValue2: _formatter.formatter.intSeparator,
            formatters2: [LengthLimitingTextInputFormatter(1)],
            onChanged2: (text) {
              _formatter.formatter.intSeparator = text.isEmpty ? ',' : text;

              _controller.syncWithFormatter(formatter: _formatter);
            },
          ),
          const SizedBox(height: 20),
          ControlsRowWidget(
            label1: 'Fractional digits: ',
            label2: 'Grouped digits: ',
            initialValue1: _formatter.formatter.ftlDigits.toString(),
            formatters1: [
              LengthLimitingTextInputFormatter(1),
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged1: (text) {
              _formatter.formatter.ftlDigits = int.tryParse(text) ?? 3;

              _controller.syncWithFormatter(formatter: _formatter);
            },
            initialValue2: _formatter.formatter.intSpDigits.toString(),
            formatters2: [
              LengthLimitingTextInputFormatter(1),
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged2: (text) {
              _formatter.formatter.intSpDigits = int.tryParse(text) ?? 3;

              _controller.syncWithFormatter(formatter: _formatter);
            },
          ),
          const SizedBox(height: 20),
          EmptyValueController(
            initialValue: _formatter.isEmptyAllowed,
            onChanged: (isAllowed) {
              _formatter.formatter.isEmptyAllowed = isAllowed;

              _controller.syncWithFormatter(formatter: _formatter);
            },
          ),
          const SizedBox(height: 50),
          Padding(
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
                        const SizedBox(height: 10),
                        Text(
                          'Controller offset: ${_controller.value.selection.baseOffset}',
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _controller,
                  inputFormatters: [_formatter],
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: true,
                    decimal: true,
                  ),
                  onSubmitted: (text) {},
                  onTapOutside: (_) {},
                  onChanged: (text) {
                    log('Text value: $text');
                    log('Double value: ${_formatter.doubleValue}');
                  },
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
        ],
      ),
    );
  }
}

class ControlFieldWidget extends StatelessWidget {
  const ControlFieldWidget({
    super.key,
    this.initialValue,
    this.formatters,
    this.onChanged,
  });

  final String? initialValue;
  final List<TextInputFormatter>? formatters;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      child: TextFormField(
        initialValue: initialValue,
        inputFormatters: formatters,
        onChanged: onChanged,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(
            vertical: 2,
            horizontal: 4,
          ),
        ),
      ),
    );
  }
}

class ControlsRowWidget extends StatelessWidget {
  const ControlsRowWidget({
    super.key,
    this.initialValue1,
    this.initialValue2,
    required this.label1,
    required this.label2,
    this.formatters1,
    this.formatters2,
    this.onChanged1,
    this.onChanged2,
  });

  final String? initialValue1;
  final String? initialValue2;
  final String label1;
  final String label2;
  final List<TextInputFormatter>? formatters1;
  final List<TextInputFormatter>? formatters2;
  final void Function(String)? onChanged1;
  final void Function(String)? onChanged2;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label1),
          ControlFieldWidget(
            initialValue: initialValue1,
            formatters: formatters1,
            onChanged: onChanged1,
          ),
          const SizedBox(width: 40),
          Text(label2),
          ControlFieldWidget(
            initialValue: initialValue2,
            formatters: formatters2,
            onChanged: onChanged2,
          ),
        ],
      ),
    );
  }
}

class EmptyValueController extends StatefulWidget {
  const EmptyValueController({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });

  final bool initialValue;
  final void Function(bool) onChanged;

  @override
  State<EmptyValueController> createState() => _EmptyValueControllerState();
}

class _EmptyValueControllerState extends State<EmptyValueController> {
  late bool value = widget.initialValue;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Allow empty value: '),
        Switch(
          value: value,
          onChanged: (value) {
            setState(() {
              this.value = value;
              widget.onChanged(this.value);
            });
          },
        ),
      ],
    );
  }
}
