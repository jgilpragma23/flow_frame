import 'package:flutter/material.dart';
import 'package:flow_frame/flow_frame.dart';

import '../../theme/app_colors.dart';
import '../../widgets/demo_widgets.dart';

class TypographyScreen extends StatelessWidget {
  const TypographyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoPage(
      title: 'Typography',
      intro:
          'FFTextStyle owns text properties only. Apply it directly with '
          'FFStyled, or combine it with other style responsibilities.',
      children: [
        DemoTopicSection(
          title: 'Responsive heading',
          description:
              'Font size, weight, alignment, and color can be selected '
              'independently at each breakpoint.',
          child: FFStyled(
            text: const FFTextStyle(
              color: AppColors.primary,
              fontSize: FFValue(xs: 22, md: 30, lg: 38),
              fontWeight: FFValue.all(FontWeight.w800),
              textAlign: FFValue(xs: TextAlign.center, md: TextAlign.start),
            ),
            child: const Text('Readable at every size'),
          ),
        ),
        const DemoCodeSample('''FFStyled(
  text: const FFTextStyle(
    color: AppColors.primary,
    fontSize: FFValue(xs: 22, md: 30, lg: 38),
    fontWeight: FFValue.all(FontWeight.w800),
    textAlign: FFValue(xs: TextAlign.center, md: TextAlign.start),
  ),
  child: const Text('Readable at every size'),
)'''),
        DemoTopicSection(
          title: 'Line height for body copy',
          description:
              'Use lineHeight as a multiplier; longer text gets more '
              'breathing room at larger breakpoints.',
          child: FFStyled(
            text: const FFTextStyle(
              fontSize: FFValue(xs: 14, lg: 18),
              lineHeight: FFValue(xs: 1.35, lg: 1.7),
            ),
            child: const Text(
              'Flow Frame resolves responsive text values using the same '
              'breakpoint scope as the grid. This paragraph adapts its size '
              'and line spacing while the rest of the interface can remain '
              'completely independent.',
            ),
          ),
        ),
        DemoTopicSection(
          title: 'Combine responsibilities only when useful',
          description:
              'FFStyle remains a convenience composition; each part can '
              'also be applied on its own.',
          child: FFStyled(
            text: const FFTextStyle(
              color: AppColors.primary,
              fontWeight: FFValue.all(FontWeight.w700),
            ),
            decoration: const FFDecorationStyle(
              backgroundColor: FFValue(xs: AppColors.primarySoft),
            ),
            layout: const FFLayoutStyle(
              padding: FFSpacing(all: FFValue.all(12)),
            ),
            child: const Text('Text + decoration + layout'),
          ),
        ),
      ],
    );
  }
}
