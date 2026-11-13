import 'package:flutter/material.dart';
import 'package:flow_frame/flow_frame.dart';

import '../../theme/app_colors.dart';
import '../../widgets/demo_widgets.dart';

class ContainerScreen extends StatelessWidget {
  const ContainerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoPage(
      title: 'Container',
      intro:
          'FFContainer uses the available width up to maxSize and centers '
          'itself. The gray background is the free space on the sides.',
      children: [
        for (final max in [480.0, 800.0, 1100.0])
          LayoutBuilder(
            builder: (context, constraints) => ColoredBox(
              color: AppColors.surface.resolve(context),
              child: FFStyled(
                style: const FFStyle(
                  padding: FFSpacing(all: FFValue(xs: 12, md: 16)),
                  backgroundColor: FFValue(xs: AppColors.primarySoft),
                  color: AppColors.primary,
                  fontWeight: FFValue.all(FontWeight.w600),
                ),
                child: FFContainer(
                  maxSize: max,
                  child: Text(
                    'maxSize: ${max.round()} · current width: '
                    '${constraints.maxWidth.clamp(0, max).round()} px',
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
