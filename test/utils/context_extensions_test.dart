import 'package:flow_frame/flow_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FFContextExtensions', () {
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
        tester.view.physicalSize = Size(entry.key, 800);
        tester.view.devicePixelRatio = 1;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(builder: (context) => Text(context.breakpoint.name)),
          ),
        );

        expect(find.text(entry.value.name), findsOneWidget);
      }

      addTearDown(tester.view.reset);
    });

    testWidgets('responsive hereda el último valor definido y permite null', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1000, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      late String? resolved;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              resolved = context.responsive<String>(
                xs: 'mobile',
                md: 'desktop',
              );
              return Text(resolved ?? 'sin valor');
            },
          ),
        ),
      );

      expect(resolved, 'desktop');
      expect(find.text('desktop'), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              resolved = context.responsive<String>();
              return Text(resolved ?? 'sin valor');
            },
          ),
        ),
      );

      expect(resolved, isNull);
      expect(find.text('sin valor'), findsOneWidget);
    });
  });
}
