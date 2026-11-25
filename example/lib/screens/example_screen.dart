import 'package:flutter/material.dart';
import 'package:flow_frame/flow_frame.dart';

import '../theme/app_colors.dart';
import '../theme/example_styles.dart';
import '../widgets/example_card_body.dart';

class ExampleScreen extends StatelessWidget {
  const ExampleScreen({super.key});

  static bool _openedMenu = false;

  @override
  Widget build(BuildContext context) {
    if (!_openedMenu && Uri.base.queryParameters['open'] == '1') {
      _openedMenu = true;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => FFScaffold.of(context).openMenu(),
      );
    }

    return SingleChildScrollView(
      child: FFContainer(
        maxSize: 1280,
        child: FFStyled(
          style: const FFStyle(
            padding: FFSpacing(
              horizontal: FFValue(xs: 16, md: 32),
              vertical: FFValue(xs: 16, md: 32),
            ),
          ),
          child: FFFlex(
            gap: const FFValue(xs: 16, md: 24),
            children: [
              FFStyledItem(
                style: const FFStyle(
                  textStyle: FFValue(
                    xs: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                    md: TextStyle(fontSize: 34),
                  ),
                  textAlign: FFValue(xs: TextAlign.center, md: TextAlign.start),
                ),
                child: Text(
                  'Current breakpoint: ${context.breakpoint.name} '
                  '(${MediaQuery.sizeOf(context).width.round()} px)',
                ),
              ),
              const FFStyledItem(
                style: FFStyle(color: AppColors.muted),
                child: Text(
                  'Grid with col: FFValue(xs: 12, md: 6, lg: 4). '
                  'One per row on xs, two on md, and three on lg; '
                  'items that do not fit wrap to the next row.',
                ),
              ),
              FFFlex(
                direction: const FFValue.all(FFDirectionEnum.horizontal),
                gap: const FFValue(xs: 12, md: 16),
                children: [
                  for (var i = 1; i <= 5; i++)
                    FFStyledItem(
                      col: const FFValue(xs: 12, md: 6, lg: 4),
                      style: exampleCardStyle.merge(
                        const FFStyle(height: FFValue.all(100)),
                      ),
                      child: ExampleCardBody(
                        'Product $i',
                        'col: xs 12, md 6, lg 4',
                      ),
                    ),
                ],
              ),
              const FFStyledItem(
                style: FFStyle(color: AppColors.muted),
                child: Text(
                  'Mixed in one row: col 3, fill, and a naturally sized icon. '
                  'On xs, col 12 uses the full row and the others wrap below.',
                ),
              ),
              FFFlex(
                direction: const FFValue.all(FFDirectionEnum.horizontal),
                gap: const FFValue(xs: 12, md: 16),
                crossAxisAlignment: const FFValue.all(
                  CrossAxisAlignment.center,
                ),
                children: [
                  FFStyledItem(
                    col: const FFValue(xs: 12, md: 3),
                    style: exampleCardStyle.merge(
                      const FFStyle(height: FFValue.all(100)),
                    ),
                    child: const ExampleCardBody('Filters', 'col: xs 12, md 3'),
                  ),
                  FFStyledItem(
                    fill: const FFValue.all(true),
                    style: exampleCardStyle.merge(
                      const FFStyle(height: FFValue.all(100)),
                    ),
                    child: const ExampleCardBody('Search', 'fill: true'),
                  ),
                  const FFStyledItem(
                    fill: FFValue.all(false),
                    style: FFStyle(color: AppColors.primary),
                    child: Icon(Icons.tune, size: 32),
                  ),
                ],
              ),
              const FFStyledItem(
                style: FFStyle(color: AppColors.muted),
                child: Text(
                  'FFFlex is vertical on xs/sm and horizontal from md onward. '
                  'Card B uses visible: FFValue(xs: false, md: true).',
                ),
              ),
              FFFlex(
                direction: const FFValue(
                  xs: FFDirectionEnum.vertical,
                  md: FFDirectionEnum.horizontal,
                ),
                gap: const FFValue(xs: 12, md: 16),
                children: [
                  _card('A', 'fill: md true'),
                  FFStyledItem(
                    fill: const FFValue(md: true),
                    style: exampleCardStyle.merge(
                      const FFStyle(
                        visible: FFValue(xs: false, md: true),
                        backgroundColor: FFValue(
                          xs: FFColor.adaptive(
                            light: Color(0xFFFFF4D6),
                            dark: Color(0xFF3A2E14),
                          ),
                        ),
                      ),
                    ),
                    child: const ExampleCardBody('B', 'hidden on xs/sm'),
                  ),
                  _card('C', 'fill: md true'),
                ],
              ),
              const FFStyledItem(
                style: FFStyle(color: AppColors.muted),
                child: Text(
                  'A 260 px sidebar with the content filling the rest, from md onward',
                ),
              ),
              FFFlex(
                direction: const FFValue(
                  xs: FFDirectionEnum.vertical,
                  md: FFDirectionEnum.horizontal,
                ),
                gap: const FFValue(xs: 12, md: 16),
                children: [
                  FFStyledItem(
                    fill: const FFValue.all(false),
                    style: exampleCardStyle.merge(
                      const FFStyle(width: FFValue(md: 260)),
                    ),
                    child: const ExampleCardBody('Sidebar', 'width: md 260'),
                  ),
                  FFStyledItem(
                    fill: const FFValue(md: true),
                    style: exampleCardStyle,
                    child: const ExampleCardBody('Content', 'fill: md true'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  FFStyledItem _card(String title, String note) => FFStyledItem(
    fill: const FFValue(md: true),
    style: exampleCardStyle,
    child: ExampleCardBody(title, note),
  );
}
