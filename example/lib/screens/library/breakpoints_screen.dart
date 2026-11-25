import 'package:flutter/material.dart';
import 'package:flow_frame/flow_frame.dart';

import '../../theme/app_colors.dart';
import '../../widgets/demo_widgets.dart';

class BreakpointsScreen extends StatelessWidget {
  const BreakpointsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return DemoPage(
      title: 'Breakpoints',
      intro:
          'FFBreakpointScope sets responsive thresholds for a subtree. '
          'FFValue cascades from xs to the active breakpoint.',
      children: [
        DemoTopicSection(
          title: 'Active breakpoint',
          description:
              'Current viewport: ${width.round()} px · '
              'resolved as ${context.breakpoint.name}.',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final breakpoint in BreakpointEnum.values)
                Chip(
                  avatar: Icon(
                    breakpoint == context.breakpoint
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    size: 16,
                  ),
                  label: Text(breakpoint.name),
                ),
            ],
          ),
        ),
        DemoCodeSample('''FFBreakpointScope(
  breakpoints: const FFBreakpoints(
    sm: 640, md: 900, lg: 1200, xl: 1600,
  ),
  child: const MyApp(),
)

final columns = FFValue(xs: 12, md: 6, lg: 4);'''),
        DemoTopicSection(
          title: 'One value, responsive layout',
          description:
              'The cards change from one column to two and then three '
              'without duplicating the page.',
          child: FFFlex(
            direction: const FFValue.all(FFDirectionEnum.horizontal),
            gap: const FFValue.all(12),
            children: [
              for (var i = 1; i <= 3; i++)
                FFStyledItem(
                  col: const FFValue(xs: 12, md: 6, lg: 4),
                  style: const FFStyle(
                    padding: FFSpacing(all: FFValue.all(16)),
                    backgroundColor: FFValue(xs: AppColors.primarySoft),
                    color: AppColors.primary,
                  ),
                  child: Text('FFValue(xs: 12, md: 6, lg: 4) · $i'),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
