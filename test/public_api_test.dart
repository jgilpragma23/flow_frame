import 'package:flow_frame/colors.dart' as colors;
import 'package:flow_frame/containers.dart' as containers;
import 'package:flow_frame/grid.dart' as grid;
import 'package:flow_frame/navigation.dart' as navigation;
import 'package:flow_frame/responsive.dart' as responsive;
import 'package:flow_frame/styling.dart' as styling;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('each capability has an independent public import', () {
    const thresholds = responsive.FFBreakpoints(md: 900);
    const value = responsive.FFValue(xs: 8, md: 16);
    const color = colors.FFColor.fixed(Color(0xFF123456));
    const style = styling.FFStyle(
      padding: styling.FFSpacing(all: responsive.FFValue.all(8)),
    );
    const textStyle = styling.FFTextStyle(
      fontSize: responsive.FFValue(xs: 14, md: 18),
    );
    const decorationStyle = styling.FFDecorationStyle(
      backgroundColor: responsive.FFValue(xs: color),
    );
    const layoutStyle = styling.FFLayoutStyle(
      padding: styling.FFSpacing(all: responsive.FFValue.all(12)),
    );
    final composedStyle = styling.FFStyle.compose(
      text: textStyle,
      decoration: decorationStyle,
      layout: layoutStyle,
    );
    const item = grid.FFItem(
      col: responsive.FFValue(xs: 12, md: 6),
      child: SizedBox(),
    );
    final styledItem = styling.FFStyledItem.compose(
      col: const responsive.FFValue(xs: 12, md: 6),
      decoration: const styling.FFDecorationStyle(
        backgroundColor: responsive.FFValue(
          xs: colors.FFColor.fixed(Color(0xFFE3F2FD)),
        ),
      ),
      child: const SizedBox(),
    );
    const flex = grid.FFFlex(children: [item]);
    const container = containers.FFContainer(child: SizedBox());
    const destination = navigation.FFDestination(
      id: 'home',
      icon: Icon(IconData(0xe318, fontFamily: 'MaterialIcons')),
      label: 'Home',
    );

    expect(thresholds.md, 900);
    expect(value.resolve(responsive.BreakpointEnum.md), 16);
    expect(color, isA<colors.FFColor>());
    expect(style, isA<styling.FFStyle>());
    expect(textStyle.fontSize?.resolve(responsive.BreakpointEnum.md), 18);
    expect(decorationStyle.backgroundColor, isNotNull);
    expect(layoutStyle.padding?.all?.resolve(responsive.BreakpointEnum.xs), 12);
    expect(composedStyle.text.fontSize, textStyle.fontSize);
    expect(
      composedStyle.decoration.backgroundColor,
      decorationStyle.backgroundColor,
    );
    expect(composedStyle.layout.padding, layoutStyle.padding);
    expect(flex, isA<grid.FFFlex>());
    expect(styledItem.col?.resolve(responsive.BreakpointEnum.md), 6);
    expect(styledItem.style.backgroundColor, isNotNull);
    expect(container, isA<containers.FFContainer>());
    expect(destination.id, 'home');
  });

  testWidgets('applies independent style concerns without navigation', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: styling.FFStyled(
          text: const styling.FFTextStyle(fontSize: responsive.FFValue.all(18)),
          decoration: const styling.FFDecorationStyle(
            backgroundColor: responsive.FFValue(
              xs: colors.FFColor.fixed(Color(0xFFE3F2FD)),
            ),
          ),
          layout: const styling.FFLayoutStyle(
            padding: styling.FFSpacing(all: responsive.FFValue.all(12)),
          ),
          child: const Text('Independiente'),
        ),
      ),
    );

    final textStyle = tester.widget<DefaultTextStyle>(
      find
          .ancestor(
            of: find.text('Independiente'),
            matching: find.byType(DefaultTextStyle),
          )
          .first,
    );
    final coloredBox = tester.widget<ColoredBox>(
      find
          .ancestor(
            of: find.text('Independiente'),
            matching: find.byType(ColoredBox),
          )
          .first,
    );
    final padding = tester.widget<Padding>(
      find
          .ancestor(
            of: find.text('Independiente'),
            matching: find.byType(Padding),
          )
          .first,
    );

    expect(textStyle.style.fontSize, 18);
    expect(coloredBox.color, const Color(0xFFE3F2FD));
    expect(padding.padding, const EdgeInsets.all(12));
  });
}
