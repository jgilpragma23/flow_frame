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
const brand = WRColor.adaptive(light: purple, dark: lightPurple);
const muted = WRColor.fixed(gray);

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

  group('WRStyle', () {
    const title = WRStyle(
      textStyle: WRValue(
        xs: TextStyle(fontSize: 20, fontFamily: 'Inter'),
        md: TextStyle(fontSize: 28),
      ),
      fontWeight: WRValue(md: FontWeight.bold),
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
          .merge(const WRStyle(fontSize: WRValue(xs: 12)))
          .toTextStyle(context);
      expect(style.fontSize, 12);
    });

    testWidgets('resolve calcula todos los valores', (tester) async {
      final context = await pumpContext(tester, tablet);
      final resolved = const WRStyle(
        padding: WRSpacing(all: WRValue(xs: 8, md: 16)),
        margin: WRSpacing(top: WRValue(xs: 4)),
        backgroundColor: muted,
        maxWidth: WRValue(md: 640),
        visible: WRValue(xs: false, md: true),
      ).resolve(context);
      expect(resolved.padding, const EdgeInsets.all(16));
      expect(resolved.margin, const EdgeInsets.only(top: 4));
      expect(resolved.backgroundColor, gray);
      expect(resolved.maxWidth, 640);
      expect(resolved.visible, isTrue);
    });

    test('merge: el segundo gana donde define algo', () {
      const base = WRStyle(
        padding: WRSpacing(all: WRValue(xs: 8)),
        textStyle: WRValue(xs: TextStyle(fontSize: 14)),
        color: muted,
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
      expect(merged.color, muted);
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
        DefaultTextStyle(
          style: const TextStyle(fontFamily: 'Inter'),
          child: Builder(
            builder: (context) => WRContainer(
              style: const WRStyle(
                textStyle: WRValue(xs: TextStyle(fontSize: 14)),
                color: muted,
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
      expect(a.color, gray);

      final b = styleOf('b');
      expect(b.fontSize, 14);
      expect(b.color, gray);
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

  group('WRFlex', () {
    Rect rectOf(WidgetTester tester, String key) =>
        tester.getRect(find.byKey(Key(key)));

    Widget layout() => const WRFlex(
      direction: WRValue(xs: Axis.vertical, md: Axis.horizontal),
      gap: WRValue(xs: 8, md: 20),
      children: [
        WRItem(child: SizedBox(key: Key('a'), width: 200, height: 10)),
        WRItem(
          fill: WRValue(md: true),
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
        const WRFlex(
          direction: WRValue.all(Axis.horizontal),
          children: [
            WRItem(
              fill: WRValue.all(true),
              child: SizedBox(key: Key('a'), height: 10),
            ),
            WRItem(
              fill: WRValue.all(true),
              child: SizedBox(key: Key('b'), height: 10),
            ),
          ],
        ),
      );
      expect(rectOf(tester, 'a').width, 500);
      expect(rectOf(tester, 'b').width, 500);
    });

    testWidgets('fill cambia por breakpoint', (tester) async {
      const flex = WRFlex(
        direction: WRValue.all(Axis.horizontal),
        children: [
          WRItem(
            fill: WRValue(xs: false, sm: true, lg: false),
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
        const WRFlex(
          gap: WRValue.all(10),
          children: [
            SizedBox(key: Key('a'), height: 10),
            WRItem(
              style: WRStyle(visible: WRValue(xs: false)),
              child: SizedBox(height: 10),
            ),
            SizedBox(key: Key('c'), height: 10),
          ],
        ),
      );
      expect(rectOf(tester, 'c').top, rectOf(tester, 'a').bottom + 10);
    });

    testWidgets('order cambia la posición por breakpoint', (tester) async {
      const flex = WRFlex(
        children: [
          WRItem(child: SizedBox(key: Key('a'), height: 10)),
          WRItem(
            order: WRValue(xs: -1, md: 0),
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
      Widget flex(int order) => WRFlex(
        children: [
          const WRItem(child: _Counter(key: Key('a'))),
          WRItem(
            order: WRValue.all(order),
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
      Widget grid(int count) => WRFlex(
        direction: const WRValue.all(Axis.horizontal),
        gap: const WRValue.all(16),
        children: [
          for (var i = 0; i < count; i++)
            WRItem(
              col: const WRValue(xs: 12, md: 6, lg: 4),
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
          const WRFlex(
            direction: WRValue.all(Axis.horizontal),
            gap: WRValue.all(16),
            children: [
              WRItem(
                col: WRValue.all(3),
                child: SizedBox(key: Key('a'), height: 10),
              ),
              WRItem(
                fill: WRValue.all(true),
                child: SizedBox(key: Key('b'), height: 10),
              ),
              SizedBox(key: Key('c'), width: 40, height: 10),
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
        const flex = WRFlex(
          direction: WRValue.all(Axis.horizontal),
          children: [
            SizedBox(key: Key('a'), width: 100, height: 10),
            WRItem(
              col: WRValue(xs: 12),
              fill: WRValue(md: true),
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
          const WRFlex(
            direction: WRValue.all(Axis.horizontal),
            mainAxisAlignment: WRValue.all(MainAxisAlignment.center),
            children: [
              WRItem(
                col: WRValue.all(12),
                child: SizedBox(key: Key('a'), height: 10),
              ),
              SizedBox(key: Key('b'), width: 200, height: 10),
            ],
          ),
        );
        expect(rectOf(tester, 'b'), const Rect.fromLTWH(400, 10, 200, 10));
      });

      testWidgets('stretch iguala la altura de la fila', (tester) async {
        await pump(
          tester,
          tablet,
          const WRFlex(
            direction: WRValue.all(Axis.horizontal),
            crossAxisAlignment: WRValue.all(CrossAxisAlignment.stretch),
            children: [
              WRItem(
                col: WRValue.all(6),
                child: SizedBox(key: Key('a'), height: 10),
              ),
              WRItem(
                col: WRValue.all(6),
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
            child: WRFlex(
              direction: WRValue.all(Axis.horizontal),
              children: [
                WRItem(
                  col: WRValue.all(6),
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
          const WRFlex(
            children: [
              WRItem(
                col: WRValue.all(6),
                child: SizedBox(key: Key('a'), height: 10),
              ),
            ],
          ),
        );
        expect(rectOf(tester, 'a').width, 1000);
      });
    });

    testWidgets('fill dentro de un scroll vertical no falla', (tester) async {
      await pump(
        tester,
        phone,
        const SingleChildScrollView(
          child: WRFlex(
            children: [
              WRItem(
                fill: WRValue.all(true),
                child: SizedBox(key: Key('a'), height: 10),
              ),
            ],
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(rectOf(tester, 'a').height, 10);
    });

    testWidgets('WRItem fuera de WRFlex ignora fill y aplica el estilo', (
      tester,
    ) async {
      await pump(
        tester,
        phone,
        const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WRItem(
              fill: WRValue.all(true),
              style: WRStyle(padding: WRSpacing(all: WRValue(xs: 10))),
              child: SizedBox(key: Key('a'), height: 10),
            ),
          ],
        ),
      );
      expect(rectOf(tester, 'a'), const Rect.fromLTWH(10, 10, 380, 10));
    });
  });

  group('WRScaffold', () {
    const destinations = [
      WRDestination(id: 'inicio', icon: Icon(Icons.home), label: 'Inicio'),
      WRDestination(
        id: 'ventas',
        icon: Icon(Icons.store),
        label: 'Ventas',
        children: [
          WRDestination(
            id: 'ventas/pedidos',
            icon: Icon(Icons.receipt),
            label: 'Pedidos',
          ),
          WRDestination(
            id: 'ventas/clientes',
            icon: Icon(Icons.people),
            label: 'Clientes',
          ),
        ],
      ),
      WRDestination(
        id: 'reportes',
        icon: Icon(Icons.bar_chart),
        label: 'Reportes',
        visible: WRValue(xs: false, md: true),
      ),
    ];

    Future<void> pumpScaffold(
      WidgetTester tester,
      Size screen, {
      String currentRoute = 'inicio',
      WRValue<WRNavStyle>? responsive,
      ValueChanged<String>? onRouteSelected,
      List<WRDestination> items = destinations,
    }) {
      tester.view.physicalSize = screen;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      return tester.pumpWidget(
        MaterialApp(
          home: WRScaffold(
            destinations: items,
            currentRoute: currentRoute,
            onRouteSelected: onRouteSelected ?? (_) {},
            responsive: responsive,
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
      expect(tester.getTopLeft(find.text('cuerpo')).dx, greaterThan(280));

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
          WRDestination(id: 'inicio', icon: Icon(Icons.home), label: 'Inicio'),
          WRDestination(
            id: 'config',
            icon: Icon(Icons.settings),
            label: 'Config',
            alwaysOpen: true,
            children: [
              WRDestination(
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
        responsive: const WRValue.all(WRNavStyle(type: WRNavigation.drawer)),
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
      const style = WRValue(
        xs: WRNavStyle(
          backgroundColor: WRColor.fixed(Color(0xFF112233)),
          iconColor: WRColor.fixed(Color(0xFF445566)),
        ),
        md: WRNavStyle(type: WRNavigation.drawer),
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
        responsive: const WRValue(lg: WRNavStyle(subRoutesAlwaysVisible: true)),
      );
      expect(visibleText('Pedidos'), findsOneWidget);
      expect(find.byIcon(Icons.expand_more), findsNothing);
    });

    test('WRNavStyle.resolveMerged une desde xs', () {
      const value = WRValue(
        xs: WRNavStyle(type: WRNavigation.bottom, expanded: false),
        md: WRNavStyle(type: WRNavigation.rail),
        lg: WRNavStyle(expanded: true),
      );
      expect(
        value.resolveMerged(Breakpoint.sm),
        const WRNavStyle(type: WRNavigation.bottom, expanded: false),
      );
      expect(
        value.resolveMerged(Breakpoint.xl),
        const WRNavStyle(type: WRNavigation.rail, expanded: true),
      );
    });

    testWidgets('WRScaffold.of abre el menú', (tester) async {
      await pumpScaffold(tester, tablet);
      WRScaffold.of(tester.element(find.text('cuerpo'))).openMenu();
      await tester.pumpAndSettle();
      expect(visibleText('Reportes'), findsWidgets);
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
