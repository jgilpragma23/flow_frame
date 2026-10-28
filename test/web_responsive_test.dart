import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:web_responsive/web_responsive.dart';

/// Monta [child] en una pantalla de tamaño [screen].
Future<void> pump(WidgetTester tester, Size screen, Widget child) {
  tester.view.physicalSize = screen;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  return tester.pumpWidget(
    Directionality(textDirection: TextDirection.ltr, child: child),
  );
}

/// Monta un `Builder` y devuelve su context.
Future<BuildContext> pumpContext(
  WidgetTester tester,
  Size screen, {
  WRThemeData? theme,
  ThemeData? material,
}) async {
  late BuildContext result;
  Widget child = Builder(
    builder: (context) {
      result = context;
      return const SizedBox();
    },
  );
  if (theme != null) child = WRTheme(data: theme, child: child);
  if (material != null) child = Theme(data: material, child: child);
  await pump(tester, screen, child);
  return result;
}

const phone = Size(400, 800);
const tablet = Size(1000, 800);

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

    testWidgets('respeta breakpoints personalizados del tema', (tester) async {
      final context = await pumpContext(
        tester,
        const Size(700, 800),
        theme: const WRThemeData(breakpoints: WRBreakpoints(sm: 500, md: 650)),
      );
      expect(context.breakpoint, Breakpoint.md);
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

    test('merge combina breakpoint por breakpoint', () {
      const merged = WRValue(xs: 1, md: 2);
      expect(
        merged.merge(const WRValue(md: 3, xl: 4)),
        const WRValue(xs: 1, md: 3, xl: 4),
      );
    });

    test('los TextStyle se combinan en cascada', () {
      const value = WRValue(
        xs: TextStyle(fontSize: 14, fontFamily: 'Inter'),
        md: TextStyle(fontSize: 18),
      );
      final md = value.resolveMerged(Breakpoint.lg)!;
      expect(md.fontSize, 18);
      expect(md.fontFamily, 'Inter');
    });
  });

  group('WRSpacing', () {
    const spacing = WRSpacing(
      all: WRValue(xs: 8, md: 16, xl: 24),
      horizontal: WRValue(lg: 32),
      vertical: WRValue(sm: 12),
      top: WRValue(md: 20),
    );

    test('gana el breakpoint más cercano y luego el más específico', () {
      double top(Breakpoint b) => spacing.resolve(b).top;
      expect(top(Breakpoint.xs), 8);
      expect(top(Breakpoint.sm), 12);
      expect(top(Breakpoint.md), 20);
      expect(top(Breakpoint.lg), 20);
      expect(top(Breakpoint.xl), 24);
    });

    test('resuelve los cuatro lados', () {
      expect(
        spacing.resolve(Breakpoint.lg),
        const EdgeInsets.fromLTRB(32, 20, 32, 16),
      );
    });

    test('los lados sin valor quedan en 0', () {
      expect(
        const WRSpacing(top: WRValue(xs: 4)).resolve(Breakpoint.md),
        const EdgeInsets.only(top: 4),
      );
    });
  });

  group('WRColor', () {
    testWidgets('los colores de la paleta siguen a themeMode', (tester) async {
      var context = await pumpContext(
        tester,
        phone,
        theme: const WRThemeData(themeMode: ThemeMode.dark),
      );
      expect(WRColor.primary.resolve(context), WRPalette.dark.primary);

      context = await pumpContext(
        tester,
        phone,
        theme: const WRThemeData(themeMode: ThemeMode.light),
      );
      expect(WRColor.primary.resolve(context), WRPalette.light.primary);
    });

    testWidgets('sin themeMode sigue al Theme de Material', (tester) async {
      const adaptive = WRColor.adaptive(
        light: Color(0xFFFFFFFF),
        dark: Color(0xFF000000),
      );
      final context = await pumpContext(
        tester,
        phone,
        material: ThemeData(brightness: Brightness.dark),
      );
      expect(context.wrBrightness, Brightness.dark);
      expect(adaptive.resolve(context), const Color(0xFF000000));
    });

    testWidgets('fixed no cambia con el tema', (tester) async {
      final context = await pumpContext(
        tester,
        phone,
        theme: const WRThemeData(themeMode: ThemeMode.dark),
      );
      expect(
        const WRColor.fixed(Color(0xFF123456)).resolve(context),
        const Color(0xFF123456),
      );
    });
  });

  group('WRStyle', () {
    const title = WRStyle(
      textStyle: WRValue(
        xs: TextStyle(fontSize: 20, fontFamily: 'Inter'),
        md: TextStyle(fontSize: 28),
      ),
      fontWeight: WRValue(md: FontWeight.bold),
      color: WRColor.primary,
    );

    testWidgets('toTextStyle aplica color y peso encima de la base', (
      tester,
    ) async {
      var context = await pumpContext(tester, phone);
      var style = title.toTextStyle(context);
      expect(style.fontSize, 20);
      expect(style.fontWeight, isNull);
      expect(style.color, WRPalette.light.primary);

      context = await pumpContext(tester, tablet);
      style = title.toTextStyle(context);
      expect(style.fontSize, 28);
      expect(style.fontFamily, 'Inter');
      expect(style.fontWeight, FontWeight.bold);
    });

    testWidgets('fontSize suelto gana sobre textStyle', (tester) async {
      final context = await pumpContext(tester, phone);
      final style = title
          .merge(const WRStyle(fontSize: WRValue(xs: 12)))
          .toTextStyle(context);
      expect(style.fontSize, 12);
    });

    testWidgets('resolve calcula todos los valores', (tester) async {
      final context = await pumpContext(tester, tablet);
      final resolved = const WRStyle(
        padding: WRSpacing(all: WRValue(xs: 8, md: 16)),
        margin: WRSpacing(top: WRValue(xs: 4)),
        backgroundColor: WRColor.surface,
        maxWidth: WRValue(md: 640),
        visible: WRValue(xs: false, md: true),
      ).resolve(context);
      expect(resolved.padding, const EdgeInsets.all(16));
      expect(resolved.margin, const EdgeInsets.only(top: 4));
      expect(resolved.backgroundColor, WRPalette.light.surface);
      expect(resolved.maxWidth, 640);
      expect(resolved.visible, isTrue);
    });

    test('merge: el segundo gana donde define algo', () {
      const base = WRStyle(
        padding: WRSpacing(all: WRValue(xs: 8)),
        textStyle: WRValue(xs: TextStyle(fontSize: 14)),
        color: WRColor.text,
      );
      final merged = base.merge(
        const WRStyle(
          padding: WRSpacing(top: WRValue(xs: 20)),
          textStyle: WRValue(xs: TextStyle(fontWeight: FontWeight.bold)),
          visible: WRValue(xs: false),
        ),
      );
      expect(
        merged.padding!.resolve(Breakpoint.xs),
        const EdgeInsets.fromLTRB(8, 20, 8, 8),
      );
      expect(
        merged.textStyle!.resolveMerged(Breakpoint.xs),
        const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      );
      expect(merged.color, WRColor.text);
      expect(merged.visible, const WRValue(xs: false));
    });
  });

  group('WRContainer', () {
    const box = SizedBox(key: Key('c'), height: 10);
    Rect rect(WidgetTester tester) =>
        tester.getRect(find.byKey(const Key('c')));

    testWidgets('limita el ancho a maxSize y centra', (tester) async {
      await pump(
        tester,
        const Size(2000, 800),
        const WRContainer(maxSize: 1280, child: box),
      );
      expect(rect(tester).width, 1280);
      expect(rect(tester).left, 360);
    });

    testWidgets('ocupa todo el ancho si la pantalla es menor', (tester) async {
      await pump(tester, phone, const WRContainer(maxSize: 1280, child: box));
      expect(rect(tester).width, 400);
    });

    testWidgets('aplica el padding del breakpoint actual', (tester) async {
      const container = WRContainer(
        maxSize: 1280,
        style: WRStyle(padding: WRSpacing(all: WRValue(xs: 8, md: 16))),
        child: box,
      );

      await pump(tester, phone, container);
      expect(rect(tester).width, 400 - 16);

      await pump(tester, tablet, container);
      expect(rect(tester).width, 1000 - 32);
    });

    testWidgets('los Text de adentro heredan el estilo', (tester) async {
      await pump(
        tester,
        phone,
        WRTheme(
          data: const WRThemeData(
            textStyle: WRValue(xs: TextStyle(fontFamily: 'Inter')),
          ),
          child: Builder(
            builder: (context) => WRContainer(
              style: const WRStyle(
                textStyle: WRValue(xs: TextStyle(fontSize: 14)),
                color: WRColor.textMuted,
              ),
              child: Column(
                children: [
                  const Text('a'),
                  Text(
                    'b',
                    style: const WRStyle(
                      fontWeight: WRValue(xs: FontWeight.bold),
                    ).toTextStyle(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      TextStyle styleOf(String text) {
        final rich = tester.widget<RichText>(
          find.descendant(of: find.text(text), matching: find.byType(RichText)),
        );
        return rich.text.style!;
      }

      final a = styleOf('a');
      expect(a.fontSize, 14);
      expect(a.fontFamily, 'Inter');
      expect(a.color, WRPalette.light.textMuted);

      final b = styleOf('b');
      expect(b.fontSize, 14);
      expect(b.color, WRPalette.light.textMuted);
      expect(b.fontWeight, FontWeight.bold);
    });

    testWidgets('visible: false oculta el contenido', (tester) async {
      const container = WRContainer(
        style: WRStyle(visible: WRValue(xs: false, md: true)),
        child: box,
      );
      await pump(tester, phone, container);
      expect(find.byKey(const Key('c')), findsNothing);

      await pump(tester, tablet, container);
      expect(find.byKey(const Key('c')), findsOneWidget);
    });
  });
}
