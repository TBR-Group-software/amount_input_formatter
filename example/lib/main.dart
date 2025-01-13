import 'dart:developer';

import 'package:example/pages/advanced_example_page.dart';
import 'package:example/pages/rtl_example_page.dart';
import 'package:flutter/material.dart';
import 'package:amount_input_formatter/amount_input_formatter.dart';

void main() {
  runApp(const AmountFormatterExampleApp());
}

class AmountFormatterExampleApp extends StatelessWidget {
  const AmountFormatterExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Amount input Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const GeneralExamplePage(),
    );
  }
}

class GeneralExamplePage extends StatefulWidget {
  const GeneralExamplePage({
    super.key,
  });

  @override
  State<GeneralExamplePage> createState() => _GeneralExamplePageState();
}

class _GeneralExamplePageState extends State<GeneralExamplePage> {
  final _controller = TextEditingController();
  final _formatter = AmountInputFormatter(
    integralLength: 10,
    groupSeparator: ',',
    fractionalDigits: 3,
    decimalSeparator: '.',
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AdvancedExamplePage(),
                  ),
                );
              },
              child: const Text('Advanced Example'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const RtlExamplePage(),
                  ),
                );
              },
              child: const Text('RTL Example'),
            ),
          ],
        ),
      ),
    );
  }
}
