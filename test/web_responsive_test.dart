import 'package:flow_frame/flow_frame.dart';
import 'package:flow_frame/src/atoms/atoms.dart';
import 'package:flow_frame/src/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
  ThemeData? material,
}) async {
  late BuildContext result;
  Widget child = Builder(
    builder: (context) {
      result = context;
      return const SizedBox();
    },
  );
  if (material != null) child = Theme(data: material, child: child);
  await pump(tester, screen, child);
  return result;
}

const phone = Size(400, 800);
const tablet = Size(1000, 800);

const purple = Color(0xFF7C3AED);
const lightPurple = Color(0xFFA78BFA);
const gray = Color(0xFF666666);
const brand = FFColor.adaptive(light: purple, dark: lightPurple);
const muted = FFColor.fixed(gray);

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

    testWidgets('respeta breakpoints personalizados', (tester) async {
      WRBreakpoints.current = const WRBreakpoints(sm: 500, md: 650);
      addTearDown(() => WRBreakpoints.current = const WRBreakpoints());
      final context = await pumpContext(tester, const Size(700, 800));
      expect(context.breakpoint, Breakpoint.md);
      expect(Breakpoint.fromWidth(550), Breakpoint.sm);
    });
  });

  group('FFValue', () {
    test('hace cascada mobile-first', () {
      const value = FFValue(xs: 8, md: 16);
      expect(value.resolve(Breakpoint.xs), 8);
      expect(value.resolve(Breakpoint.sm), 8);
      expect(value.resolve(Breakpoint.md), 16);
      expect(value.resolve(Breakpoint.xl), 16);
    });

    test('devuelve null antes del primer valor', () {
      const value = FFValue(md: 1);
      expect(value.resolve(Breakpoint.sm), isNull);
      expect(value.resolve(Breakpoint.lg), 1);
    });

    test('merge combina breakpoint por breakpoint', () {
      const merged = FFValue(xs: 1, md: 2);
      expect(
        merged.merge(const FFValue(md: 3, xl: 4)),
        const FFValue(xs: 1, md: 3, xl: 4),
      );
    });

    test('los TextStyle se combinan en cascada', () {
      const value = FFValue(
        xs: TextStyle(fontSize: 14, fontFamily: 'Inter'),
        md: TextStyle(fontSize: 18),
      );
      final md = value.resolveMerged(Breakpoint.lg)!;
      expect(md.fontSize, 18);
      expect(md.fontFamily, 'Inter');
    });
  });

  group('FFSpacing', () {
    const spacing = FFSpacing(
      all: FFValue(xs: 8, md: 16, xl: 24),
      horizontal: FFValue(lg: 32),
      vertical: FFValue(sm: 12),
      top: FFValue(md: 20),
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
        const FFSpacing(top: FFValue(xs: 4)).resolve(Breakpoint.md),
        const EdgeInsets.only(top: 4),
      );
    });
  });

  group('FFColor', () {
    testWidgets('adaptive sigue al Theme de la app', (tester) async {
      var context = await pumpContext(
        tester,
        phone,
        material: ThemeData(brightness: Brightness.dark),
      );
      expect(brand.resolve(context), lightPurple);

      context = await pumpContext(
        tester,
        phone,
        material: ThemeData(brightness: Brightness.light),
      );
      expect(brand.resolve(context), purple);
    });

    testWidgets('fixed no cambia con el modo', (tester) async {
      final context = await pumpContext(
        tester,
        phone,
        material: ThemeData(brightness: Brightness.dark),
      );
      expect(muted.resolve(context), gray);
    });
  });

  group('FFStyle', () {
    const title = FFStyle(
      textStyle: FFValue(
        xs: TextStyle(fontSize: 20, fontFamily: 'Inter'),
        md: TextStyle(fontSize: 28),
      ),
      fontWeight: FFValue(md: FontWeight.bold),
      color: brand,
    );

    testWidgets('toTextStyle aplica color y peso encima de la base', (
      tester,
    ) async {
      var context = await pumpContext(tester, phone);
      var style = title.toTextStyle(context);
      expect(style.fontSize, 20);
      expect(style.fontWeight, isNull);
      expect(style.color, purple);

      context = await pumpContext(tester, tablet);
      style = title.toTextStyle(context);
      expect(style.fontSize, 28);
      expect(style.fontFamily, 'Inter');
      expect(style.fontWeight, FontWeight.bold);
    });

    testWidgets('fontSize suelto gana sobre textStyle', (tester) async {
      final context = await pumpContext(tester, phone);
      final style = title
          .merge(const FFStyle(fontSize: FFValue(xs: 12)))
          .toTextStyle(context);
      expect(style.fontSize, 12);
    });

    testWidgets('resolve calcula todos los valores', (tester) async {
      final context = await pumpContext(tester, tablet);
      final resolved = const FFStyle(
        padding: FFSpacing(all: FFValue(xs: 8, md: 16)),
        margin: FFSpacing(top: FFValue(xs: 4)),
        backgroundColor: muted,
        maxWidth: FFValue(md: 640),
        visible: FFValue(xs: false, md: true),
      ).resolve(context);
      expect(resolved.padding, const EdgeInsets.all(16));
      expect(resolved.margin, const EdgeInsets.only(top: 4));
      expect(resolved.backgroundColor, gray);
      expect(resolved.maxWidth, 640);
      expect(resolved.visible, isTrue);
    });

    test('merge: el segundo gana donde define algo', () {
      const base = FFStyle(
        padding: FFSpacing(all: FFValue(xs: 8)),
        textStyle: FFValue(xs: TextStyle(fontSize: 14)),
        color: muted,
      );
      final merged = base.merge(
        const FFStyle(
          padding: FFSpacing(top: FFValue(xs: 20)),
          textStyle: FFValue(xs: TextStyle(fontWeight: FontWeight.bold)),
          visible: FFValue(xs: false),
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
      expect(merged.color, muted);
      expect(merged.visible, const FFValue(xs: false));
    });
  });

  group('FFContainer', () {
    const box = SizedBox(key: Key('c'), height: 10);
    Rect rect(WidgetTester tester) =>
        tester.getRect(find.byKey(const Key('c')));

    testWidgets('limita el ancho a maxSize y centra', (tester) async {
      await pump(
        tester,
        const Size(2000, 800),
        const FFContainer(maxSize: 1280, child: box),
      );
      expect(rect(tester).width, 1280);
      expect(rect(tester).left, 360);
    });

    testWidgets('ocupa todo el ancho si la pantalla es menor', (tester) async {
      await pump(tester, phone, const FFContainer(maxSize: 1280, child: box));
      expect(rect(tester).width, 400);
    });

    testWidgets('aplica el padding del breakpoint actual', (tester) async {
      const container = FFContainer(
        maxSize: 1280,
        style: FFStyle(padding: FFSpacing(all: FFValue(xs: 8, md: 16))),
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
        DefaultTextStyle(
          style: const TextStyle(fontFamily: 'Inter'),
          child: Builder(
            builder: (context) => FFContainer(
              style: const FFStyle(
                textStyle: FFValue(xs: TextStyle(fontSize: 14)),
                color: muted,
              ),
              child: Column(
                children: [
                  const Text('a'),
                  Text(
                    'b',
                    style: const FFStyle(
                      fontWeight: FFValue(xs: FontWeight.bold),
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
      expect(a.color, gray);

      final b = styleOf('b');
      expect(b.fontSize, 14);
      expect(b.color, gray);
      expect(b.fontWeight, FontWeight.bold);
    });

    testWidgets('visible: false oculta el contenido', (tester) async {
      const container = FFContainer(
        style: FFStyle(visible: FFValue(xs: false, md: true)),
        child: box,
      );
      await pump(tester, phone, container);
      expect(find.byKey(const Key('c')), findsNothing);

      await pump(tester, tablet, container);
      expect(find.byKey(const Key('c')), findsOneWidget);
    });
  });

  group('FFFlex', () {
    Rect rectOf(WidgetTester tester, String key) =>
        tester.getRect(find.byKey(Key(key)));

    Widget layout() => const FFFlex(
      direction: FFValue(xs: Axis.vertical, md: Axis.horizontal),
      gap: FFValue(xs: 8, md: 20),
      children: [
        FFItem(
          fill: FFValue.all(false),
          child: SizedBox(key: Key('a'), width: 200, height: 10),
        ),
        FFItem(
          fill: FFValue(md: true),
          child: SizedBox(key: Key('b'), height: 10),
        ),
      ],
    );

    testWidgets('en vertical apila y ocupa todo el ancho', (tester) async {
      await pump(tester, phone, layout());
      final a = rectOf(tester, 'a');
      final b = rectOf(tester, 'b');
      expect(a.width, 400);
      expect(b.width, 400);
      expect(b.top, a.bottom + 8);
    });

    testWidgets('en horizontal fill ocupa el espacio que sobra', (
      tester,
    ) async {
      await pump(tester, tablet, layout());
      final a = rectOf(tester, 'a');
      final b = rectOf(tester, 'b');
      expect(a.width, 200);
      expect(b.width, 1000 - 20 - 200);
      expect(b.left, a.right + 20);
    });

    testWidgets('varios fill se reparten en partes iguales', (tester) async {
      await pump(
        tester,
        tablet,
        const FFFlex(
          direction: FFValue.all(Axis.horizontal),
          children: [
            FFItem(
              fill: FFValue.all(true),
              child: SizedBox(key: Key('a'), height: 10),
            ),
            FFItem(
              fill: FFValue.all(true),
              child: SizedBox(key: Key('b'), height: 10),
            ),
          ],
        ),
      );
      expect(rectOf(tester, 'a').width, 500);
      expect(rectOf(tester, 'b').width, 500);
    });

    testWidgets('fill cambia por breakpoint', (tester) async {
      const flex = FFFlex(
        direction: FFValue.all(Axis.horizontal),
        children: [
          FFItem(
            fill: FFValue(xs: false, sm: true, lg: false),
            child: SizedBox(key: Key('a'), width: 100, height: 10),
          ),
        ],
      );
      await pump(tester, phone, flex);
      expect(rectOf(tester, 'a').width, 100);

      await pump(tester, const Size(700, 800), flex);
      expect(rectOf(tester, 'a').width, 700);

      await pump(tester, const Size(1300, 800), flex);
      expect(rectOf(tester, 'a').width, 100);
    });

    testWidgets('los ocultos no dejan separación', (tester) async {
      await pump(
        tester,
        phone,
        const FFFlex(
          gap: FFValue.all(10),
          children: [
            SizedBox(key: Key('a'), height: 10),
            FFItem(
              style: FFStyle(visible: FFValue(xs: false)),
              child: SizedBox(height: 10),
            ),
            SizedBox(key: Key('c'), height: 10),
          ],
        ),
      );
      expect(rectOf(tester, 'c').top, rectOf(tester, 'a').bottom + 10);
    });

    testWidgets('order cambia la posición por breakpoint', (tester) async {
      const flex = FFFlex(
        children: [
          FFItem(child: SizedBox(key: Key('a'), height: 10)),
          FFItem(
            order: FFValue(xs: -1, md: 0),
            child: SizedBox(key: Key('b'), height: 10),
          ),
        ],
      );
      await pump(tester, phone, flex);
      expect(rectOf(tester, 'b').top, lessThan(rectOf(tester, 'a').top));

      await pump(tester, tablet, flex);
      expect(rectOf(tester, 'a').top, lessThan(rectOf(tester, 'b').top));
    });

    testWidgets('el orden no hace perder el estado', (tester) async {
      Widget flex(int order) => FFFlex(
        children: [
          const FFItem(child: _Counter(key: Key('a'))),
          FFItem(
            order: FFValue.all(order),
            child: const _Counter(key: Key('b')),
          ),
        ],
      );
      await pump(tester, phone, flex(0));
      tester.state<_CounterState>(find.byKey(const Key('b'))).value = 7;
      await pump(tester, phone, flex(-1));
      expect(tester.state<_CounterState>(find.byKey(const Key('b'))).value, 7);
    });

    group('col', () {
      Widget grid(int count) => FFFlex(
        direction: const FFValue.all(Axis.horizontal),
        gap: const FFValue.all(16),
        children: [
          for (var i = 0; i < count; i++)
            FFItem(
              col: const FFValue(xs: 12, md: 6, lg: 4),
              child: SizedBox(key: Key('$i'), height: 10),
            ),
        ],
      );

      testWidgets('xs: col 12, uno por fila', (tester) async {
        await pump(tester, phone, grid(3));
        for (var i = 0; i < 3; i++) {
          expect(rectOf(tester, '$i'), Rect.fromLTWH(0, i * 26.0, 400, 10));
        }
      });

      testWidgets('md: col 6, dos por fila y el resto baja', (tester) async {
        await pump(tester, tablet, grid(5));
        const w = (1000 - 16) / 2;
        expect(rectOf(tester, '0'), const Rect.fromLTWH(0, 0, w, 10));
        expect(rectOf(tester, '1'), const Rect.fromLTWH(w + 16, 0, w, 10));
        expect(rectOf(tester, '2'), const Rect.fromLTWH(0, 26, w, 10));
        expect(rectOf(tester, '3'), const Rect.fromLTWH(w + 16, 26, w, 10));
        expect(rectOf(tester, '4'), const Rect.fromLTWH(0, 52, w, 10));
      });

      testWidgets('lg: col 4, tres por fila', (tester) async {
        await pump(tester, const Size(1300, 800), grid(4));
        const w = (1300 - 32) / 3;
        expect(rectOf(tester, '2').left, closeTo(2 * (w + 16), 0.001));
        expect(rectOf(tester, '2').top, 0);
        expect(rectOf(tester, '3').topLeft, const Offset(0, 26));
        expect(rectOf(tester, '3').width, closeTo(w, 0.001));
      });

      testWidgets('col, fill y natural en la misma fila', (tester) async {
        await pump(
          tester,
          tablet,
          const FFFlex(
            direction: FFValue.all(Axis.horizontal),
            gap: FFValue.all(16),
            children: [
              FFItem(
                col: FFValue.all(3),
                child: SizedBox(key: Key('a'), height: 10),
              ),
              FFItem(
                fill: FFValue.all(true),
                child: SizedBox(key: Key('b'), height: 10),
              ),
              FFItem(
                fill: FFValue.all(false),
                child: SizedBox(key: Key('c'), width: 40, height: 10),
              ),
            ],
          ),
        );
        const col3 = 3 / 12 * (1000 + 16) - 16;
        expect(rectOf(tester, 'a').width, col3);
        expect(rectOf(tester, 'b').width, 1000 - col3 - 40 - 32);
        expect(rectOf(tester, 'c').left, 960);
        expect(rectOf(tester, 'c').top, 0);
      });

      testWidgets('el breakpoint más cercano decide entre col y fill', (
        tester,
      ) async {
        const flex = FFFlex(
          direction: FFValue.all(Axis.horizontal),
          children: [
            FFItem(
              fill: FFValue.all(false),
              child: SizedBox(key: Key('a'), width: 100, height: 10),
            ),
            FFItem(
              col: FFValue(xs: 12),
              fill: FFValue(md: true),
              child: SizedBox(key: Key('b'), height: 10),
            ),
          ],
        );
        await pump(tester, phone, flex);
        expect(rectOf(tester, 'b'), const Rect.fromLTWH(0, 10, 400, 10));

        await pump(tester, tablet, flex);
        expect(rectOf(tester, 'b'), const Rect.fromLTWH(100, 0, 900, 10));
      });

      testWidgets('mainAxisAlignment se aplica a cada fila', (tester) async {
        await pump(
          tester,
          tablet,
          const FFFlex(
            direction: FFValue.all(Axis.horizontal),
            mainAxisAlignment: FFValue.all(MainAxisAlignment.center),
            children: [
              FFItem(
                col: FFValue.all(12),
                child: SizedBox(key: Key('a'), height: 10),
              ),
              FFItem(
                fill: FFValue.all(false),
                child: SizedBox(key: Key('b'), width: 200, height: 10),
              ),
            ],
          ),
        );
        expect(rectOf(tester, 'b'), const Rect.fromLTWH(400, 10, 200, 10));
      });

      testWidgets('stretch iguala la altura de la fila', (tester) async {
        await pump(
          tester,
          tablet,
          const FFFlex(
            direction: FFValue.all(Axis.horizontal),
            crossAxisAlignment: FFValue.all(CrossAxisAlignment.stretch),
            children: [
              FFItem(
                col: FFValue.all(6),
                child: SizedBox(key: Key('a'), height: 10),
              ),
              FFItem(
                col: FFValue.all(6),
                child: SizedBox(key: Key('b'), height: 50),
              ),
            ],
          ),
        );
        expect(rectOf(tester, 'a').height, 50);
      });

      testWidgets('respeta derecha a izquierda', (tester) async {
        tester.view.physicalSize = tablet;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          const Directionality(
            textDirection: TextDirection.rtl,
            child: FFFlex(
              direction: FFValue.all(Axis.horizontal),
              children: [
                FFItem(
                  col: FFValue.all(6),
                  child: SizedBox(key: Key('a'), height: 10),
                ),
              ],
            ),
          ),
        );
        expect(rectOf(tester, 'a').left, 500);
      });

      testWidgets('col se ignora en vertical', (tester) async {
        await pump(
          tester,
          tablet,
          const FFFlex(
            direction: FFValue.all(Axis.vertical),
            children: [
              FFItem(
                col: FFValue.all(6),
                child: SizedBox(key: Key('a'), height: 10),
              ),
            ],
          ),
        );
        expect(rectOf(tester, 'a').width, 1000);
      });

      testWidgets('por defecto es horizontal: col sin direction', (
        tester,
      ) async {
        const flex = FFFlex(
          children: [
            FFItem(
              col: FFValue(xs: 4, md: 12),
              child: SizedBox(key: Key('a'), height: 10),
            ),
            FFItem(
              col: FFValue(xs: 8, md: 12),
              child: SizedBox(key: Key('b'), height: 10),
            ),
          ],
        );
        await pump(tester, phone, flex);
        expect(rectOf(tester, 'a').width, closeTo(400 / 3, 0.001));
        expect(rectOf(tester, 'b').top, 0);
        expect(rectOf(tester, 'b').left, closeTo(400 / 3, 0.001));

        await pump(tester, tablet, flex);
        expect(rectOf(tester, 'a').width, 1000);
        expect(rectOf(tester, 'b').top, 10);
      });

      testWidgets('sin col ocupa la fila completa, como en Bootstrap', (
        tester,
      ) async {
        await pump(
          tester,
          tablet,
          const FFFlex(
            gap: FFValue.all(8),
            children: [
              FFItem(child: SizedBox(key: Key('a'), width: 100, height: 10)),
              SizedBox(key: Key('b'), width: 100, height: 10),
              FFItem(
                fill: FFValue.all(false),
                child: SizedBox(key: Key('c'), width: 100, height: 10),
              ),
            ],
          ),
        );
        expect(rectOf(tester, 'a'), const Rect.fromLTWH(0, 0, 1000, 10));
        expect(rectOf(tester, 'b'), const Rect.fromLTWH(0, 18, 1000, 10));
        expect(rectOf(tester, 'c'), const Rect.fromLTWH(0, 36, 100, 10));
      });
    });

    testWidgets('fill dentro de un scroll vertical no falla', (tester) async {
      await pump(
        tester,
        phone,
        const SingleChildScrollView(
          child: FFFlex(
            children: [
              FFItem(
                fill: FFValue.all(true),
                child: SizedBox(key: Key('a'), height: 10),
              ),
            ],
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(rectOf(tester, 'a').height, 10);
    });

    testWidgets('FFItem fuera de FFFlex ignora fill y aplica el estilo', (
      tester,
    ) async {
      await pump(
        tester,
        phone,
        const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FFItem(
              fill: FFValue.all(true),
              style: FFStyle(padding: FFSpacing(all: FFValue(xs: 10))),
              child: SizedBox(key: Key('a'), height: 10),
            ),
          ],
        ),
      );
      expect(rectOf(tester, 'a'), const Rect.fromLTWH(10, 10, 380, 10));
    });
  });

  group('FFScaffold', () {
    const destinations = [
      FFDestination(id: 'inicio', icon: Icon(Icons.home), label: 'Inicio'),
      FFDestination(
        id: 'ventas',
        icon: Icon(Icons.store),
        label: 'Ventas',
        children: [
          FFDestination(
            id: 'ventas/pedidos',
            icon: Icon(Icons.receipt),
            label: 'Pedidos',
          ),
          FFDestination(
            id: 'ventas/clientes',
            icon: Icon(Icons.people),
            label: 'Clientes',
          ),
        ],
      ),
      FFDestination(
        id: 'reportes',
        icon: Icon(Icons.bar_chart),
        label: 'Reportes',
        visible: FFValue(xs: false, md: true),
      ),
    ];

    Future<void> pumpScaffold(
      WidgetTester tester,
      Size screen, {
      String currentRoute = 'inicio',
      FFValue<FFNavStyle>? responsive,
      ValueChanged<String>? onRouteSelected,
      List<FFDestination> items = destinations,
      FFBrand? brand,
      PreferredSizeWidget? appBar,
    }) {
      tester.view.physicalSize = screen;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      return tester.pumpWidget(
        MaterialApp(
          home: FFScaffold(
            destinations: items,
            currentRoute: currentRoute,
            onRouteSelected: onRouteSelected ?? (_) {},
            responsive: responsive,
            brand: brand,
            appBar: appBar,
            body: const Text('cuerpo'),
          ),
        ),
      );
    }

    Finder visibleText(String text) => find.text(text).hitTestable();

    testWidgets('xs: barra abajo sin subrutas ni ocultos', (tester) async {
      await pumpScaffold(tester, phone);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(visibleText('Ventas'), findsOneWidget);
      expect(find.text('Pedidos'), findsNothing);
      expect(find.text('Reportes'), findsNothing);
    });

    testWidgets('barra: un grupo va a su primera subruta', (tester) async {
      String? selected;
      await pumpScaffold(tester, phone, onRouteSelected: (id) => selected = id);
      await tester.tap(find.text('Ventas'));
      expect(selected, 'ventas/pedidos');
    });

    testWidgets('barra: un grupo recuerda la última subruta visitada', (
      tester,
    ) async {
      String? selected;
      await pumpScaffold(tester, phone, currentRoute: 'ventas/clientes');
      await pumpScaffold(tester, phone, onRouteSelected: (id) => selected = id);
      await tester.tap(find.text('Ventas'));
      expect(selected, 'ventas/clientes');
    });

    testWidgets('md: rail cerrado; ☰ abre el menú encima', (tester) async {
      await pumpScaffold(tester, tablet);
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(visibleText('Clientes'), findsNothing);

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      // El rail sigue ahí: el menú está encima, no lo reemplaza.
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(visibleText('Reportes'), findsWidgets);
    });

    testWidgets('overlay: elegir una subruta cierra el menú', (tester) async {
      String? selected;
      await pumpScaffold(
        tester,
        tablet,
        onRouteSelected: (id) => selected = id,
      );
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(visibleText('Ventas').last);
      await tester.pumpAndSettle();
      await tester.tap(visibleText('Clientes'));
      await tester.pumpAndSettle();
      expect(selected, 'ventas/clientes');
      expect(visibleText('Clientes'), findsNothing);
    });

    testWidgets('rail: tocar un grupo abre el menú con el grupo abierto', (
      tester,
    ) async {
      await pumpScaffold(tester, tablet);
      await tester.tap(find.byIcon(Icons.store));
      await tester.pumpAndSettle();
      expect(visibleText('Pedidos'), findsOneWidget);
      expect(visibleText('Clientes'), findsOneWidget);
    });

    testWidgets('lg: sidebar abierto con acordeón, empuja el contenido', (
      tester,
    ) async {
      await pumpScaffold(
        tester,
        const Size(1300, 800),
        currentRoute: 'ventas/pedidos',
      );
      expect(find.byType(NavigationRail), findsNothing);
      // El grupo de la selección empieza abierto.
      expect(visibleText('Pedidos'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('cuerpo')).dx,
        greaterThanOrEqualTo(280),
      );

      // Cerrar el acordeón.
      await tester.tap(visibleText('Ventas'));
      await tester.pumpAndSettle();
      expect(visibleText('Pedidos'), findsNothing);

      // Cerrar el menú vuelve al rail.
      await tester.tap(find.byIcon(Icons.menu_open));
      await tester.pumpAndSettle();
      expect(find.byType(NavigationRail), findsOneWidget);
    });

    testWidgets('alwaysOpen: el grupo no se puede cerrar', (tester) async {
      await pumpScaffold(
        tester,
        const Size(1300, 800),
        items: const [
          FFDestination(id: 'inicio', icon: Icon(Icons.home), label: 'Inicio'),
          FFDestination(
            id: 'config',
            icon: Icon(Icons.settings),
            label: 'Config',
            alwaysOpen: true,
            children: [
              FFDestination(
                id: 'config/perfil',
                icon: Icon(Icons.person),
                label: 'Perfil',
              ),
            ],
          ),
        ],
      );
      expect(visibleText('Perfil'), findsOneWidget);
      expect(find.byIcon(Icons.expand_more), findsNothing);
      await tester.tap(visibleText('Config'));
      await tester.pumpAndSettle();
      expect(visibleText('Perfil'), findsOneWidget);
    });

    testWidgets('al cambiar de breakpoint vuelve al estado inicial', (
      tester,
    ) async {
      await pumpScaffold(tester, const Size(1300, 800));
      await tester.tap(find.byIcon(Icons.menu_open));
      await tester.pumpAndSettle();
      expect(find.byType(NavigationRail), findsOneWidget);

      await pumpScaffold(tester, tablet);
      await pumpScaffold(tester, const Size(1300, 800));
      expect(find.byType(NavigationRail), findsNothing);
    });

    testWidgets('drawer: acordeón y se cierra al elegir', (tester) async {
      String? selected;
      await pumpScaffold(
        tester,
        phone,
        responsive: const FFValue.all(FFNavStyle(type: FFNavigation.drawer)),
        onRouteSelected: (id) => selected = id,
      );
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(visibleText('Ventas'));
      await tester.pumpAndSettle();
      await tester.tap(visibleText('Pedidos'));
      await tester.pumpAndSettle();
      expect(selected, 'ventas/pedidos');
      expect(find.byType(Drawer), findsNothing);
    });

    testWidgets('responsive: cascada sobre los valores por defecto', (
      tester,
    ) async {
      const style = FFValue(
        xs: FFNavStyle(
          backgroundColor: FFColor.fixed(Color(0xFF112233)),
          iconColor: FFColor.fixed(Color(0xFF445566)),
        ),
        md: FFNavStyle(type: FFNavigation.drawer),
      );
      // xs: sigue siendo barra (por defecto) con los colores de xs.
      await pumpScaffold(tester, phone, responsive: style);
      final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(bar.backgroundColor, const Color(0xFF112233));

      // md: drawer, y hereda los colores de xs.
      await pumpScaffold(tester, tablet, responsive: style);
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      final drawer = tester.widget<Drawer>(find.byType(Drawer));
      expect(drawer.backgroundColor, const Color(0xFF112233));
    });

    testWidgets('subRoutesAlwaysVisible abre todos los grupos', (tester) async {
      await pumpScaffold(
        tester,
        const Size(1300, 800),
        responsive: const FFValue(lg: FFNavStyle(subRoutesAlwaysVisible: true)),
      );
      expect(visibleText('Pedidos'), findsOneWidget);
      expect(find.byIcon(Icons.expand_more), findsNothing);
    });

    test('FFNavStyle.resolveMerged une desde xs', () {
      const value = FFValue(
        xs: FFNavStyle(type: FFNavigation.bottom, expanded: false),
        md: FFNavStyle(type: FFNavigation.rail),
        lg: FFNavStyle(expanded: true),
      );
      expect(
        value.resolveMerged(Breakpoint.sm),
        const FFNavStyle(type: FFNavigation.bottom, expanded: false),
      );
      expect(
        value.resolveMerged(Breakpoint.xl),
        const FFNavStyle(type: FFNavigation.rail, expanded: true),
      );
    });

    testWidgets('appBar: enlaces en el app bar y grupos en dropdown', (
      tester,
    ) async {
      String? selected;
      await pumpScaffold(
        tester,
        tablet,
        responsive: const FFValue(md: FFNavStyle(type: FFNavigation.appBar)),
        onRouteSelected: (id) => selected = id,
      );
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.byType(NavigationBar), findsNothing);
      final appBar = find.byType(AppBar);
      expect(
        find.descendant(of: appBar, matching: find.text('Reportes')),
        findsOneWidget,
      );
      // Las subrutas no se ven hasta abrir el dropdown.
      expect(visibleText('Pedidos'), findsNothing);

      await tester.tap(find.text('Inicio'));
      expect(selected, 'inicio');

      await tester.tap(find.text('Ventas'));
      await tester.pumpAndSettle();
      await tester.tap(visibleText('Clientes'));
      await tester.pumpAndSettle();
      expect(selected, 'ventas/clientes');
      expect(visibleText('Clientes'), findsNothing);
    });

    testWidgets('appBar: el título queda y los enlaces van después', (
      tester,
    ) async {
      tester.view.physicalSize = tablet;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          home: FFScaffold(
            appBar: AppBar(
              title: const Text('Mi app'),
              actions: const [Icon(Icons.notifications)],
            ),
            currentRoute: 'inicio',
            onRouteSelected: (_) {},
            destinations: destinations,
            responsive: const FFValue(
              md: FFNavStyle(type: FFNavigation.appBar),
            ),
            body: const Text('cuerpo'),
          ),
        ),
      );
      final title = tester.getTopRight(find.text('Mi app'));
      final link = tester.getTopLeft(find.text('Inicio'));
      expect(link.dx, greaterThan(title.dx));
      expect(link.dy, lessThan(56));
      expect(find.byIcon(Icons.notifications), findsOneWidget);
      expect(
        FFScaffold.of(tester.element(find.text('cuerpo'))).isMenuOpen,
        isFalse,
      );
    });

    testWidgets('shadow: sombra solo donde está activa', (tester) async {
      final gradient = find.byWidgetPredicate(
        (w) =>
            w is DecoratedBox &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).gradient != null,
      );
      final boxShadow = find.byWidgetPredicate(
        (w) =>
            w is DecoratedBox &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).boxShadow != null,
      );
      const style = FFValue(md: FFNavStyle(shadow: true));

      // xs: barra sin sombra (solo se activa desde md).
      await pumpScaffold(tester, phone, responsive: style);
      expect(boxShadow, findsNothing);

      // md: rail con sombra sobre el contenido.
      await pumpScaffold(tester, tablet, responsive: style);
      expect(gradient, findsOneWidget);

      // Sin shadow no hay sombra.
      await pumpScaffold(tester, tablet);
      expect(gradient, findsNothing);

      // Barra con sombra.
      await pumpScaffold(
        tester,
        phone,
        responsive: const FFValue(xs: FFNavStyle(shadow: true)),
      );
      expect(boxShadow, findsOneWidget);
    });

    testWidgets('FFScaffold.of abre el menú', (tester) async {
      await pumpScaffold(tester, tablet);
      FFScaffold.of(tester.element(find.text('cuerpo'))).openMenu();
      await tester.pumpAndSettle();
      expect(visibleText('Reportes'), findsWidgets);
    });

    for (final (name, screen) in [
      ('rail', tablet),
      ('sidebar', const Size(1300, 800)),
    ]) {
      testWidgets('$name: ocupa toda la altura y el app bar va a su lado', (
        tester,
      ) async {
        await pumpScaffold(
          tester,
          screen,
          appBar: AppBar(title: const Text('Pedidos')),
        );
        final appBar = tester.getRect(find.byType(AppBar));
        final nav = tester.getRect(
          name == 'rail'
              ? find.byType(NavigationRail)
              : find.byIcon(Icons.menu_open),
        );
        expect(appBar.top, 0);
        expect(appBar.left, greaterThanOrEqualTo(nav.right));
        expect(nav.top, lessThan(appBar.bottom));
        // El ☰ queda a la altura del título.
        final menu = tester.getCenter(
          find.byIcon(name == 'rail' ? Icons.menu : Icons.menu_open),
        );
        expect(
          (menu.dy - tester.getCenter(find.text('Pedidos')).dy).abs(),
          lessThan(2),
        );
      });
    }

    group('marca', () {
      const brand = FFBrand(
        logo: Icon(Icons.storefront, key: Key('logo')),
        title: Text('Mi Tienda'),
        subtitle: Text('Admin'),
      );
      Finder inAppBar(Finder f) =>
          find.descendant(of: find.byType(AppBar), matching: f);

      testWidgets('sidebar: logo, título y subtítulo junto al ☰', (
        tester,
      ) async {
        await pumpScaffold(tester, const Size(1300, 800), brand: brand);
        expect(visibleText('Mi Tienda'), findsOneWidget);
        expect(visibleText('Admin'), findsOneWidget);
        final menuButton = tester.getCenter(find.byIcon(Icons.menu_open));
        final title = tester.getCenter(find.text('Mi Tienda'));
        expect((menuButton.dy - title.dy).abs(), lessThan(16));
        expect(title.dx, greaterThan(menuButton.dx));
      });

      testWidgets('rail cerrado: solo el logo, debajo del ☰', (tester) async {
        await pumpScaffold(tester, tablet, brand: brand);
        expect(visibleText('Mi Tienda'), findsNothing);
        final logo = find.byKey(const Key('logo')).hitTestable();
        expect(logo, findsOneWidget);
        expect(
          tester.getCenter(logo).dy,
          greaterThan(tester.getCenter(find.byIcon(Icons.menu)).dy),
        );
      });

      testWidgets('drawer: en el app bar y arriba del drawer', (tester) async {
        await pumpScaffold(
          tester,
          phone,
          brand: brand,
          responsive: const FFValue(xs: FFNavStyle(type: FFNavigation.drawer)),
        );
        expect(inAppBar(find.text('Mi Tienda')), findsOneWidget);
        expect(inAppBar(find.text('Admin')), findsNothing);

        await tester.tap(find.byTooltip('Open navigation menu'));
        await tester.pumpAndSettle();
        final inDrawer = find.descendant(
          of: find.byType(Drawer),
          matching: find.text('Admin'),
        );
        expect(inDrawer, findsOneWidget);
      });

      testWidgets('drawer: showInDrawer false no la repite', (tester) async {
        await pumpScaffold(
          tester,
          phone,
          brand: const FFBrand(title: Text('Mi Tienda'), showInDrawer: false),
          responsive: const FFValue(xs: FFNavStyle(type: FFNavigation.drawer)),
        );
        await tester.tap(find.byTooltip('Open navigation menu'));
        await tester.pumpAndSettle();
        expect(
          find.descendant(
            of: find.byType(Drawer),
            matching: find.text('Mi Tienda'),
          ),
          findsNothing,
        );
      });

      testWidgets('el título del AppBar manda sobre la marca', (tester) async {
        await pumpScaffold(
          tester,
          phone,
          brand: brand,
          appBar: AppBar(title: const Text('Pedidos')),
        );
        expect(inAppBar(find.text('Pedidos')), findsOneWidget);
        expect(find.text('Mi Tienda'), findsNothing);
      });

      testWidgets('appBar: la marca va antes de los enlaces', (tester) async {
        await pumpScaffold(
          tester,
          tablet,
          brand: brand,
          responsive: const FFValue(xs: FFNavStyle(type: FFNavigation.appBar)),
        );
        expect(
          tester.getCenter(inAppBar(find.text('Mi Tienda'))).dx,
          lessThan(tester.getCenter(inAppBar(find.text('Inicio'))).dx),
        );
      });

      testWidgets('onTap de la marca', (tester) async {
        var taps = 0;
        await pumpScaffold(
          tester,
          const Size(1300, 800),
          brand: FFBrand(title: const Text('Mi Tienda'), onTap: () => taps++),
        );
        await tester.tap(find.text('Mi Tienda'));
        expect(taps, 1);
      });
    });
  });

  group('FFAppBar', () {
    const brand = FFBrand(logo: Icon(Icons.store), title: Text('Mi Tienda'));
    const links = [
      FFDestination(id: 'inicio', icon: Icon(Icons.home), label: 'Inicio'),
      FFDestination(id: 'ventas', icon: Icon(Icons.store), label: 'Ventas'),
      FFDestination(
        id: 'reportes',
        icon: Icon(Icons.bar_chart),
        label: 'Reportes',
        visible: FFValue(xs: false, md: true),
      ),
    ];

    Future<void> pumpBar(WidgetTester tester, Size screen, FFAppBar bar) {
      tester.view.physicalSize = screen;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(appBar: bar, body: const Text('cuerpo')),
        ),
      );
    }

    testWidgets('se usa en un Scaffold normal con marca, título y acciones', (
      tester,
    ) async {
      await pumpBar(
        tester,
        tablet,
        FFAppBar(
          brand: brand,
          title: const Text('Pedidos'),
          actions: [
            FFAction(
              icon: const Icon(Icons.add),
              label: 'Nuevo',
              onPressed: () {},
              display: const FFValue(md: FFActionDisplay.full),
            ),
          ],
        ),
      );
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Mi Tienda'), findsOneWidget);
      expect(find.text('Pedidos'), findsOneWidget);
      expect(find.text('Nuevo'), findsOneWidget);
    });

    testWidgets('visible: oculto en xs, el contenido sube', (tester) async {
      const bar = FFAppBar(
        title: Text('Pedidos'),
        responsive: FFValue(
          xs: FFAppBarStyle(visible: false),
          md: FFAppBarStyle(visible: true),
        ),
      );
      await pumpBar(tester, phone, bar);
      expect(find.byType(AppBar), findsNothing);
      expect(tester.getTopLeft(find.text('cuerpo')).dy, 0);

      await pumpBar(tester, tablet, bar);
      expect(find.byType(AppBar), findsOneWidget);
      expect(tester.getTopLeft(find.text('cuerpo')).dy, kToolbarHeight);
    });

    testWidgets('showBrand y showTitle por breakpoint', (tester) async {
      const bar = FFAppBar(
        brand: brand,
        title: Text('Pedidos'),
        responsive: FFValue(
          xs: FFAppBarStyle(showBrand: false),
          md: FFAppBarStyle(showBrand: true, showTitle: false),
        ),
      );
      await pumpBar(tester, phone, bar);
      expect(find.text('Mi Tienda'), findsNothing);
      expect(find.text('Pedidos'), findsOneWidget);

      await pumpBar(tester, tablet, bar);
      expect(find.text('Mi Tienda'), findsOneWidget);
      expect(find.text('Pedidos'), findsNothing);
    });

    testWidgets('enlaces con visible por breakpoint', (tester) async {
      String? selected;
      FFAppBar bar() => FFAppBar(
        destinations: links,
        currentRoute: 'inicio',
        onRouteSelected: (id) => selected = id,
      );
      await pumpBar(tester, phone, bar());
      expect(find.text('Inicio'), findsOneWidget);
      expect(find.text('Reportes'), findsNothing);

      await pumpBar(tester, tablet, bar());
      await tester.tap(find.text('Reportes'));
      expect(selected, 'reportes');
    });

    testWidgets('sin onRouteSelected no muestra enlaces', (tester) async {
      await pumpBar(tester, tablet, const FFAppBar(destinations: links));
      expect(find.text('Inicio'), findsNothing);
    });

    group('dentro de FFScaffold', () {
      Future<void> pumpIn(
        WidgetTester tester,
        Size screen,
        FFAppBar bar, {
        FFValue<FFNavStyle>? responsive,
      }) {
        tester.view.physicalSize = screen;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        return tester.pumpWidget(
          MaterialApp(
            home: FFScaffold(
              destinations: links,
              currentRoute: 'inicio',
              onRouteSelected: (_) {},
              brand: brand,
              responsive: responsive,
              appBar: bar,
              body: const Text('cuerpo'),
            ),
          ),
        );
      }

      Finder inBar(String text) =>
          find.descendant(of: find.byType(AppBar), matching: find.text(text));

      testWidgets('con navegación appBar recibe marca y enlaces', (
        tester,
      ) async {
        await pumpIn(
          tester,
          tablet,
          const FFAppBar(),
          responsive: const FFValue(xs: FFNavStyle(type: FFNavigation.appBar)),
        );
        expect(inBar('Mi Tienda'), findsOneWidget);
        expect(inBar('Reportes'), findsOneWidget);
      });

      testWidgets('con rail la marca va en el menú, no en el app bar', (
        tester,
      ) async {
        await pumpIn(tester, const Size(1300, 800), const FFAppBar());
        expect(inBar('Mi Tienda'), findsNothing);
        expect(find.text('Mi Tienda'), findsOneWidget);
      });

      testWidgets('con título propio no recibe la marca', (tester) async {
        await pumpIn(tester, phone, const FFAppBar(title: Text('Pedidos')));
        expect(inBar('Pedidos'), findsOneWidget);
        expect(inBar('Mi Tienda'), findsNothing);
      });

      testWidgets('oculto deja el contenido arriba', (tester) async {
        await pumpIn(
          tester,
          phone,
          const FFAppBar(
            responsive: FFValue(xs: FFAppBarStyle(visible: false)),
          ),
        );
        expect(find.byType(AppBar), findsNothing);
        expect(tester.getTopLeft(find.text('cuerpo')).dy, 0);
      });
    });
  });

  group('FFActions', () {
    Future<void> pumpActions(
      WidgetTester tester,
      Size screen, {
      ValueChanged<String>? onPressed,
    }) {
      tester.view.physicalSize = screen;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      void tap(String id) => onPressed?.call(id);
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                FFActions(
                  actions: [
                    FFAction(
                      icon: const Icon(Icons.add),
                      label: 'Nuevo',
                      onPressed: () => tap('nuevo'),
                      display: const FFValue(
                        xs: FFActionDisplay.icon,
                        md: FFActionDisplay.full,
                      ),
                    ),
                    FFAction(
                      icon: const Icon(Icons.download),
                      label: 'Exportar',
                      onPressed: () => tap('exportar'),
                      display: const FFValue(
                        xs: FFActionDisplay.menu,
                        md: FFActionDisplay.full,
                      ),
                    ),
                    FFAction(
                      icon: const Icon(Icons.print),
                      label: 'Imprimir',
                      onPressed: () => tap('imprimir'),
                      display: const FFValue(
                        xs: FFActionDisplay.hidden,
                        md: FFActionDisplay.menu,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    testWidgets('xs: ícono, menú y oculto', (tester) async {
      String? pressed;
      await pumpActions(tester, phone, onPressed: (id) => pressed = id);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Nuevo'), findsNothing);
      expect(find.byIcon(Icons.print), findsNothing);

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      expect(find.text('Imprimir'), findsNothing);
      await tester.tap(find.text('Exportar'));
      await tester.pumpAndSettle();
      expect(pressed, 'exportar');
    });

    testWidgets('md: ícono y texto; el resto en el menú', (tester) async {
      String? pressed;
      await pumpActions(tester, tablet, onPressed: (id) => pressed = id);
      expect(find.text('Nuevo'), findsOneWidget);
      expect(find.text('Exportar'), findsOneWidget);
      await tester.tap(find.text('Nuevo'));
      expect(pressed, 'nuevo');

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Imprimir'));
      await tester.pumpAndSettle();
      expect(pressed, 'imprimir');
    });

    testWidgets('sin acciones en menú no hay ⋮', (tester) async {
      tester.view.physicalSize = tablet;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FFActions(
              actions: [FFAction(icon: Icon(Icons.add), label: 'Nuevo')],
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.more_vert), findsNothing);
      // Sin display se muestra solo el ícono.
      expect(find.text('Nuevo'), findsNothing);
      expect(find.byTooltip('Nuevo'), findsOneWidget);
    });
  });
}

class _Counter extends StatefulWidget {
  const _Counter({super.key});

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int value = 0;

  @override
  Widget build(BuildContext context) => const SizedBox(height: 10);
}
