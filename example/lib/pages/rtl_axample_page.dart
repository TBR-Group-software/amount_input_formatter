import 'package:flutter/material.dart';

class RtlExamplePage extends StatefulWidget {
  const RtlExamplePage({super.key});

  @override
  State<RtlExamplePage> createState() => _RtlExamplePageState();
}

class _RtlExamplePageState extends State<RtlExamplePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Rtl Example'),
      ),
    );
  }
}
