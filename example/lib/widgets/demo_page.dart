import 'package:flutter/material.dart';
import 'package:flow_frame/flow_frame.dart';

import '../theme/app_colors.dart';

class DemoPage extends StatelessWidget {
  const DemoPage({
    super.key,
    required this.title,
    required this.intro,
    required this.children,
  });

  final String title;
  final String intro;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: FFContainer(
        maxSize: 1280,
        child: FFStyled(
          style: const FFStyle(
            padding: FFSpacing(all: FFValue(xs: 16, md: 32)),
          ),
          child: FFFlex(
            gap: const FFValue(xs: 16, md: 24),
            children: [
              FFStyledItem(
                style: const FFStyle(
                  textStyle: FFValue(
                    xs: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                    md: TextStyle(fontSize: 30),
                  ),
                ),
                child: Text('$title · ${context.breakpoint.name}'),
              ),
              FFStyledItem(
                style: const FFStyle(color: AppColors.muted),
                child: Text(intro),
              ),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}
