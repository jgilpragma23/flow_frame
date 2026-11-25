import 'package:flutter/material.dart';
import 'package:flow_frame/flow_frame.dart';

import '../../theme/app_colors.dart';
import '../../widgets/demo_widgets.dart';

class GridScreen extends StatelessWidget {
  const GridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoPage(
      title: 'Grid',
      intro:
          'FFFlex arranges children. FFItem controls column width, fill, '
          'order, and visibility; it does not apply visual styles.',
      children: [
        DemoTopicSection(
          title: 'Grid without the styling API',
          description:
              'These cells use only FFFlex and FFItem. Their decoration is '
              'ordinary Flutter UI, independent of the grid.',
          child: FFFlex(
            direction: const FFValue.all(FFDirectionEnum.horizontal),
            gap: const FFValue.all(12),
            children: [
              for (final (col, title) in [
                (const FFValue(xs: 12, md: 6, lg: 4), 'One third'),
                (const FFValue(xs: 12, md: 6, lg: 4), 'One third'),
                (const FFValue(xs: 12, md: 6, lg: 4), 'One third'),
              ])
                FFItem(
                  col: col,
                  child: _GridTile(title, 'FFItem · col: xs 12, md 6, lg 4'),
                ),
            ],
          ),
        ),
        const DemoCodeSample('''FFFlex(
  direction: const FFValue.all(FFDirectionEnum.horizontal),
  gap: const FFValue.all(12),
  children: [
    FFItem(
      col: const FFValue(xs: 12, md: 6, lg: 4),
      child: const MyCard(),
    ),
  ],
)'''),
        DemoTopicSection(
          title: 'Opt in to styling when you need it',
          description:
              'FFStyledItem composes grid sizing with independent text, '
              'decoration, and layout styles.',
          child: FFFlex(
            direction: const FFValue.all(FFDirectionEnum.horizontal),
            gap: const FFValue.all(12),
            children: [
              FFStyledItem.compose(
                col: const FFValue(xs: 12, md: 6),
                text: const FFTextStyle(
                  color: AppColors.primary,
                  fontWeight: FFValue.all(FontWeight.w700),
                ),
                decoration: const FFDecorationStyle(
                  backgroundColor: FFValue(xs: AppColors.primarySoft),
                ),
                layout: const FFLayoutStyle(
                  padding: FFSpacing(all: FFValue.all(16)),
                ),
                child: const Text('Grid + decoration + typography'),
              ),
              const FFItem(
                fill: FFValue.all(true),
                child: _GridTile('Flexible', 'FFItem(fill: true)'),
              ),
            ],
          ),
        ),
        const DemoCodeSample('''FFStyledItem.compose(
  col: const FFValue(xs: 12, md: 6),
  text: const FFTextStyle(color: AppColors.primary),
  decoration: const FFDecorationStyle(
    backgroundColor: FFValue(xs: AppColors.primarySoft),
  ),
  child: const Text('Styled column'),
)'''),
      ],
    );
  }
}

class _GridTile extends StatelessWidget {
  const _GridTile(this.title, this.subtitle);

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    ),
  );
}
