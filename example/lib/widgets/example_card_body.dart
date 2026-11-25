import 'package:flutter/material.dart';
import 'package:flow_frame/flow_frame.dart';

import '../theme/app_colors.dart';
import '../theme/example_styles.dart';

class ExampleCardBody extends StatelessWidget {
  const ExampleCardBody(this.title, this.note, {super.key});

  final String title;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: exampleLabelStyle.toTextStyle(context)),
        const SizedBox(height: 4),
        Text(
          note,
          style: const FFStyle(color: AppColors.muted).toTextStyle(context),
        ),
      ],
    );
  }
}
