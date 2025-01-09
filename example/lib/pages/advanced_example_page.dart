import 'dart:developer';

import 'package:amount_input_formatter/amount_input_formatter.dart';
import 'package:flutter/material.dart';

class AdvancedExamplePage extends StatefulWidget {
  const AdvancedExamplePage({super.key});

  @override
  State<AdvancedExamplePage> createState() => _AdvancedExamplePageState();
}

class _AdvancedExamplePageState extends State<AdvancedExamplePage> {
  final AmountInputFormatter _formatter = AmountInputFormatter(
    initialValue: 1234567890.0987654321,
    fractionalDigits: 10,
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
      ),
    );
  }
}
