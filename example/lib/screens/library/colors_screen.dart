import 'package:flutter/material.dart';
import 'package:flow_frame/flow_frame.dart';

import '../../theme/app_colors.dart';
import '../../theme/color_utils.dart';
import '../../widgets/demo_widgets.dart';

class ColorsScreen extends StatelessWidget {
  const ColorsScreen({super.key});

  static const _palette = [
    ('background', AppColors.background),
    ('surface', AppColors.surface),
    ('primary', AppColors.primary),
    ('primarySoft', AppColors.primarySoft),
    ('muted', AppColors.muted),
  ];

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DemoPage(
      title: 'Colors',
      intro:
          'FFColor.adaptive(light: ..., dark: ...) selects a color based on '
          'the Theme. Current mode: ${dark ? 'dark' : 'light'}.',
      children: [
        FFFlex(
          direction: const FFValue.all(FFDirectionEnum.horizontal),
          gap: const FFValue.all(12),
          children: [
            for (final (name, color) in _palette)
              FFStyledItem(
                col: const FFValue(xs: 6, md: 4, lg: 2),
                style: const FFStyle(
                  backgroundColor: FFValue(xs: AppColors.surface),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 72,
                      decoration: BoxDecoration(
                        color: color.resolve(context),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          DemoNote(colorToHex(color.resolve(context))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        FFStyled(
          style: const FFStyle(
            padding: FFSpacing(all: FFValue(xs: 16, md: 24)),
            backgroundColor: FFValue(xs: AppColors.surface),
          ),
          child: FFContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FFStyledItem(
                  style: FFStyle(
                    fontSize: FFValue.all(20),
                    fontWeight: FFValue.all(FontWeight.w700),
                    color: AppColors.primary,
                  ),
                  child: Text('A card using the palette'),
                ),
                const SizedBox(height: 6),
                const FFStyledItem(
                  style: FFStyle(color: AppColors.muted),
                  child: Text(
                    'Surface background, primary title, and muted text.',
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(onPressed: () {}, child: const Text('Action')),
              ],
            ),
          ),
        ),
      ],
    );
  }

}
