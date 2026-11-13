import 'package:flutter/material.dart';
import 'package:flow_frame/flow_frame.dart';

import '../../theme/app_colors.dart';
import '../../widgets/demo_widgets.dart';

const _badge = FFStyle(
  padding: FFSpacing(
    horizontal: FFValue(xs: 10, md: 16),
    vertical: FFValue(xs: 6, md: 10),
  ),
  fontWeight: FFValue.all(FontWeight.w600),
  fontSize: FFValue(xs: 13, md: 15),
  backgroundColor: FFValue(xs: AppColors.surface),
);

const _variants = [
  ('base', FFStyle()),
  (
    'primary',
    FFStyle(
      backgroundColor: FFValue(xs: AppColors.primarySoft),
      color: AppColors.primary,
    ),
  ),
  (
    'success',
    FFStyle(
      backgroundColor: FFValue(
        xs: FFColor.adaptive(light: Color(0xFFDCFCE7), dark: Color(0xFF14361F)),
      ),
      color: FFColor.adaptive(
        light: Color(0xFF15803D),
        dark: Color(0xFF4ADE80),
      ),
    ),
  ),
  (
    'danger',
    FFStyle(
      backgroundColor: FFValue(
        xs: FFColor.adaptive(light: Color(0xFFFEE2E2), dark: Color(0xFF451A1A)),
      ),
      color: FFColor.adaptive(
        light: Color(0xFFB91C1C),
        dark: Color(0xFFF87171),
      ),
    ),
  ),
];

class StylesScreen extends StatelessWidget {
  const StylesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoPage(
      title: 'Styles',
      intro:
          'FFStyle combines text, color, background, size, and spacing. Each '
          'value can change per breakpoint, and styles can be combined with merge.',
      children: [
        _section(
          context,
          'Text: fontSize xs 20 · md 28 · lg 40, centered on xs',
          const FFStyledItem(
            style: FFStyle(
              fontSize: FFValue(xs: 20, md: 28, lg: 40),
              fontWeight: FFValue(xs: FontWeight.w600, lg: FontWeight.w900),
              textAlign: FFValue(xs: TextAlign.center, md: TextAlign.start),
              color: AppColors.primary,
            ),
            child: Text('Sales this month'),
          ),
        ),
        _section(
          context,
          'Paragraph: fontSize xs 14 · lg 18, lineHeight xs 1.3 · lg 1.7',
          const FFStyledItem(
            style: FFStyle(
              fontSize: FFValue(xs: 14, lg: 18),
              lineHeight: FFValue(xs: 1.3, lg: 1.7),
            ),
            child: Text(
              'Text grows and has more breathing room on larger screens; on '
              'phones it is more compact to fit without scrolling. '
              'All of this comes from the same FFStyle.',
            ),
          ),
        ),
        _section(
          context,
          'Variants with _badge.merge(variant): padding and size change per '
          'breakpoint, while each variant provides its color',
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final (name, variant) in _variants)
                FFStyledItem(style: _badge.merge(variant), child: Text(name)),
            ],
          ),
          natural: true,
        ),
        _section(
          context,
          'Size: width xs 100% · md 360 · lg 480, height xs 64 · md 96',
          const FFStyledItem(
            style: FFStyle(
              width: FFValue(xs: double.infinity, md: 360, lg: 480),
              height: FFValue(xs: 64, md: 96),
              backgroundColor: FFValue(xs: AppColors.primarySoft),
              padding: FFSpacing(all: FFValue.all(12)),
              color: AppColors.primary,
            ),
            child: Text('Card'),
          ),
          natural: true,
        ),
      ],
    );
  }

  /// With [natural], the child keeps its natural width and aligns left;
  /// otherwise it uses the full width to demonstrate `textAlign`.
  Widget _section(
    BuildContext context,
    String note,
    Widget child, {
    bool natural = false,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      DemoNote(note),
      const SizedBox(height: 8),
      natural ? Align(alignment: Alignment.centerLeft, child: child) : child,
    ],
  );
}
