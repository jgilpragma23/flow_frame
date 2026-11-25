import 'package:flutter/material.dart';
import 'package:flow_frame/flow_frame.dart';

import '../../theme/app_colors.dart';
import '../../widgets/demo_widgets.dart';
import '../../utils/responsive_label.dart';

const _marginColor = FFColor.adaptive(
  light: Color(0xFFFDE7C8),
  dark: Color(0xFF4A3312),
);
const _paddingColor = FFColor.adaptive(
  light: Color(0xFFCDEFD9),
  dark: Color(0xFF173B26),
);

class SpacingScreen extends StatelessWidget {
  const SpacingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoPage(
      title: 'Spacing',
      intro:
          'FFSpacing with a value per breakpoint. Orange = margin, '
          'green = padding, blue = content.',
      children: [
        _legend(context),
        _box(
          context,
          'padding all: xs 8 · md 24 · lg 40\nmargin all: xs 0 · md 16 · lg 32',
          padding: const FFValue(xs: 8, md: 24, lg: 40),
          margin: const FFValue(xs: 0, md: 16, lg: 32),
        ),
        _box(
          context,
          'padding horizontal: xs 12 · md 48 · lg 96, vertical: 8',
          padding: const FFValue(xs: 12, md: 48, lg: 96),
          vertical: const FFValue.all(8),
        ),
        _box(
          context,
          'margin left: xs 0 · md 64 · lg 160 (indentation)',
          padding: const FFValue.all(12),
          marginLeft: const FFValue(xs: 0, md: 64, lg: 160),
        ),
      ],
    );
  }

  Widget _legend(BuildContext context) => Wrap(
    spacing: 16,
    runSpacing: 8,
    children: [
      for (final (name, color) in [
        ('margin', _marginColor),
        ('padding', _paddingColor),
        ('content', AppColors.primarySoft),
      ])
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 14, height: 14, color: color.resolve(context)),
            const SizedBox(width: 6),
            DemoNote(name),
          ],
        ),
    ],
  );

  Widget _box(
    BuildContext context,
    String code, {
    required FFValue<double> padding,
    FFValue<double>? vertical,
    FFValue<double>? margin,
    FFValue<double>? marginLeft,
  }) {
    final now = [
      'padding ${pxFor(padding, context)}',
      if (margin != null) 'margin ${pxFor(margin, context)}',
      if (marginLeft != null) 'margin left ${pxFor(marginLeft, context)}',
    ].join(' · ');
    return ColoredBox(
      color: _marginColor.resolve(context),
      child: FFStyled(
        style: FFStyle(
          margin: FFSpacing(all: margin, left: marginLeft),
          padding: vertical == null
              ? FFSpacing(all: padding)
              : FFSpacing(horizontal: padding, vertical: vertical),
          backgroundColor: FFValue(xs: _paddingColor),
        ),
        child: FFContainer(
          child: FFStyled(
            style: const FFStyle(
              padding: FFSpacing(all: FFValue.all(12)),
              backgroundColor: FFValue(xs: AppColors.primarySoft),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  code,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                ),
                const SizedBox(height: 6),
                DemoNote('now: $now'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
