import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:web_responsive/web_responsive.dart';

void main() {
  group('WRBreakpoints', () {
    const breakpoints = WRBreakpoints();

    test('asigna cada ancho a su breakpoint', () {
      expect(breakpoints.of(0), Breakpoint.xs);
      expect(breakpoints.of(599), Breakpoint.xs);
      expect(breakpoints.of(600), Breakpoint.sm);
      expect(breakpoints.of(840), Breakpoint.md);
      expect(breakpoints.of(1200), Breakpoint.lg);
      expect(breakpoints.of(1600), Breakpoint.xl);
    });

    test('compara breakpoints por orden', () {
      expect(Breakpoint.md >= Breakpoint.sm, isTrue);
      expect(Breakpoint.xs < Breakpoint.xl, isTrue);
      expect(Breakpoint.lg <= Breakpoint.md, isFalse);
    });
  });

  group('WRValue', () {
    test('hace cascada mobile-first', () {
      const value = WRValue(xs: 8, md: 16);
      expect(value.resolve(Breakpoint.xs), 8);
      expect(value.resolve(Breakpoint.sm), 8);
      expect(value.resolve(Breakpoint.md), 16);
      expect(value.resolve(Breakpoint.xl), 16);
    });

    test('devuelve null antes del primer valor', () {
      const value = WRValue(md: 1);
      expect(value.resolve(Breakpoint.sm), isNull);
      expect(value.resolve(Breakpoint.lg), 1);
    });
  });

  group('WRPadding', () {
    test('cada lado hace su propia cascada', () {
      const padding = WRPadding.symmetric(
        horizontal: WRValue(xs: 8, lg: 32),
        vertical: WRValue(md: 16),
      );
      expect(
        padding.resolve(Breakpoint.xs),
        const EdgeInsets.symmetric(horizontal: 8),
      );
      expect(
        padding.resolve(Breakpoint.md),
        const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      );
      expect(
        padding.resolve(Breakpoint.lg),
        const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      );
    });
  });

  group('WRContainer', () {
    Future<void> pump(WidgetTester tester, Size screen, Widget child) {
      tester.view.physicalSize = screen;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      return tester.pumpWidget(
        Directionality(textDirection: TextDirection.ltr, child: child),
      );
    }

    testWidgets('limita el ancho a maxSize y centra', (tester) async {
      await pump(
        tester,
        const Size(2000, 800),
        const WRContainer(
          maxSize: 1280,
          child: SizedBox(key: Key('c'), height: 10),
        ),
      );
      final rect = tester.getRect(find.byKey(const Key('c')));
      expect(rect.width, 1280);
      expect(rect.left, 360);
    });

    testWidgets('ocupa todo el ancho si la pantalla es menor', (tester) async {
      await pump(
        tester,
        const Size(400, 800),
        const WRContainer(
          maxSize: 1280,
          child: SizedBox(key: Key('c'), height: 10),
        ),
      );
      expect(tester.getRect(find.byKey(const Key('c'))).width, 400);
    });

    testWidgets('aplica el padding del breakpoint actual', (tester) async {
      final container = WRContainer(
        maxSize: 1280,
        padding: WRPadding.all(xs: 8, md: 16),
        child: const SizedBox(key: Key('c'), height: 10),
      );

      await pump(tester, const Size(400, 800), container);
      expect(tester.getRect(find.byKey(const Key('c'))).width, 400 - 16);

      await pump(tester, const Size(1000, 800), container);
      expect(tester.getRect(find.byKey(const Key('c'))).width, 1000 - 32);
    });

    testWidgets('respeta breakpoints personalizados del tema', (tester) async {
      late Breakpoint bp;
      await pump(
        tester,
        const Size(700, 800),
        WRTheme(
          data: const WRThemeData(breakpoints: WRBreakpoints(sm: 500, md: 650)),
          child: Builder(
            builder: (context) {
              bp = context.breakpoint;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(bp, Breakpoint.md);
    });
  });
}
