import 'dart:developer';

import 'package:amount_input_formatter/amount_input_formatter.dart';
import 'package:flutter/material.dart';

class RtlExamplePage extends StatefulWidget {
  const RtlExamplePage({super.key});

  @override
  State<RtlExamplePage> createState() => _RtlExamplePageState();
}

class _RtlExamplePageState extends State<RtlExamplePage> {
  final _controller = TextEditingController();
  final _formatter = AmountInputFormatter();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Rtl Example'),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Center(
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
                          'Formatted value: ${_formatter.formattedValue} embedded in text',
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'القيمة المنسقة: ${_formatter.formattedValue} مُضمن في النص',
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'القيمة المنسقة: ${_formatter.ltrEnforcedValue} مُضمن في النص',
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
      ),
    );
  }
}
