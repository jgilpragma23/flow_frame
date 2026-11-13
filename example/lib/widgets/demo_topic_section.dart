import 'package:flutter/material.dart';

import 'demo_note.dart';

class DemoTopicSection extends StatelessWidget {
  const DemoTopicSection({
    super.key,
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 4),
      DemoNote(description),
      const SizedBox(height: 10),
      child,
    ],
  );
}
