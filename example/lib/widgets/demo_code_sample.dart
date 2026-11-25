import 'package:flutter/material.dart';

class DemoCodeSample extends StatelessWidget {
  const DemoCodeSample(this.code, {super.key});

  final String code;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
    ),
    child: SelectableText(
      code,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        fontFamily: 'monospace',
        height: 1.5,
      ),
    ),
  );
}
