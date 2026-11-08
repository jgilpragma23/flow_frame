import 'package:flow_frame/flow_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Size size;
  late bool resolveResponsive;
  late String? xs;
  late String? md;
  late String? resolved;
  late Widget sut;
  late Widget Function() buildSut;

  void setViewport(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  setUp(() {
    size = Size(400, 800);
    resolveResponsive = false;
    xs = 'mobile';
    md = 'desktop';
    resolved = null;
    buildSut = () => MaterialApp(
      home: Builder(
        builder: (context) {
          if (resolveResponsive) {
            resolved = context.responsive<String>(xs: xs, md: md);
            return Text(resolved ?? 'sin valor');
          }
          return Text(context.breakpoint.name);
        },
      ),
    );
    sut = buildSut();
  });

  testWidgets('resuelve el breakpoint según el ancho disponible', (
    tester,
  ) async {
    final widths = <double, BreakpointEnum>{
      400: BreakpointEnum.xs,
      600: BreakpointEnum.sm,
      840: BreakpointEnum.md,
      1200: BreakpointEnum.lg,
      1600: BreakpointEnum.xl,
    };

    for (final entry in widths.entries) {
      size = Size(entry.key, 800);
      sut = buildSut();
      setViewport(tester, size);
      await tester.pumpWidget(sut);

      expect(find.text(entry.value.name), findsOneWidget);
    }
  });

  testWidgets('responsive hereda el último valor definido y permite null', (
    tester,
  ) async {
    size = Size(1000, 800);
    resolveResponsive = true;
    sut = buildSut();
    setViewport(tester, size);
    await tester.pumpWidget(sut);

    expect(resolved, 'desktop');
    expect(find.text('desktop'), findsOneWidget);

    xs = null;
    md = null;
    sut = buildSut();
    await tester.pumpWidget(sut);

    expect(resolved, isNull);
    expect(find.text('sin valor'), findsOneWidget);
  });
}
