import 'package:flutter/material.dart';
import 'package:flow_frame/flow_frame.dart';

import '../theme/app_colors.dart';

class DemoNote extends StatelessWidget {
  const DemoNote(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const FFStyle(
      color: AppColors.muted,
      fontSize: FFValue.all(13),
    ).toTextStyle(context),
  );
}
