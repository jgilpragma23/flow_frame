import 'package:flow_frame/flow_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Rect _rect(WidgetTester tester, String key) =>
    tester.getRect(find.byKey(Key(key)));

void main() {
  late Size size;
  late Size phoneSize;
  late Size tabletSize;
  late TextDirection textDirection;
  late Widget child;
  late Widget sut;
  late Widget Function() buildSut;

  void setViewport(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  setUp(() {
    phoneSize = Size(400, 800);
    tabletSize = Size(1000, 800);
    size = phoneSize;
    textDirection = TextDirection.ltr;
    child = SizedBox.shrink();
    buildSut = () => MaterialApp(
      home: Directionality(
        textDirection: textDirection,
        child: Scaffold(body: child),
      ),
    );
    sut = buildSut();
  });

  testWidgets('cambia dirección, separación y alineación por breakpoint', (
    tester,
  ) async {
    const flex = FFFlex(
      direction: FFValue(
        xs: FFDirectionEnum.vertical,
        md: FFDirectionEnum.horizontal,
      ),
      gap: FFValue(xs: 8, md: 20),
      children: [
        FFItem(
          fill: FFValue.all(false),
          child: SizedBox(key: Key('a'), width: 60, height: 20),
        ),
        FFItem(
          fill: FFValue.all(false),
          child: SizedBox(key: Key('b'), width: 60, height: 20),
        ),
      ],
    );
    child = flex;
    sut = buildSut();
    setViewport(tester, size);
    await tester.pumpWidget(sut);
    expect(_rect(tester, 'b').top, _rect(tester, 'a').bottom + 8);

    size = tabletSize;
    sut = buildSut();
    setViewport(tester, size);
    await tester.pumpWidget(sut);
    expect(_rect(tester, 'b').left, _rect(tester, 'a').right + 20);
  });

  testWidgets('por defecto apila hijos sin sizing; no deja huecos al ocultar', (
    tester,
  ) async {
    child = const FFFlex(
      gap: FFValue.all(12),
      children: [
        SizedBox(key: Key('first'), height: 20),
        FFStyledItem(
          style: FFStyle(visible: FFValue.all(false)),
          child: SizedBox(height: 10),
        ),
        SizedBox(key: Key('last'), height: 20),
      ],
    );
    sut = buildSut();
    setViewport(tester, size);
    await tester.pumpWidget(sut);
    expect(_rect(tester, 'last').top, _rect(tester, 'first').bottom + 12);
    expect(find.byType(FFItem), findsNothing);
  });

  testWidgets('ordena elementos y revierte el orden estable', (tester) async {
    const flex = FFFlex(
      direction: FFValue.all(FFDirectionEnum.verticalReverse),
      children: [
        FFItem(
          order: FFValue.all(1),
          child: SizedBox(key: Key('a'), height: 10),
        ),
        FFItem(
          order: FFValue.all(-1),
          child: SizedBox(key: Key('b'), height: 10),
        ),
        FFItem(
          order: FFValue.all(1),
          child: SizedBox(key: Key('c'), height: 10),
        ),
      ],
    );
    child = flex;
    sut = buildSut();
    setViewport(tester, size);
    await tester.pumpWidget(sut);
    expect(_rect(tester, 'c').top, lessThan(_rect(tester, 'a').top));
    expect(_rect(tester, 'a').top, lessThan(_rect(tester, 'b').top));
  });

  testWidgets('un fill y varias columnas distribuyen el ancho disponible', (
    tester,
  ) async {
    child = const FFFlex(
      direction: FFValue.all(FFDirectionEnum.horizontal),
      gap: FFValue.all(12),
      children: [
        FFItem(
          col: FFValue.all(3),
          child: SizedBox(key: Key('quarter'), height: 10),
        ),
        FFItem(
          fill: FFValue.all(true),
          child: SizedBox(key: Key('fill'), height: 10),
        ),
      ],
    );
    size = tabletSize;
    sut = buildSut();
    setViewport(tester, size);
    await tester.pumpWidget(sut);
    expect(_rect(tester, 'quarter').width, 241);
    expect(_rect(tester, 'fill').width, 747);
    expect(_rect(tester, 'fill').left, _rect(tester, 'quarter').right + 12);
  });

  testWidgets(
    'col y fill cambian en cascada, col gana en el mismo breakpoint',
    (tester) async {
      const flex = FFFlex(
        direction: FFValue.all(FFDirectionEnum.horizontal),
        children: [
          FFItem(
            col: FFValue(md: 6),
            fill: FFValue(xs: true, md: true),
            child: SizedBox(key: Key('item'), height: 10),
          ),
        ],
      );
      child = flex;
      sut = buildSut();
      setViewport(tester, size);
      await tester.pumpWidget(sut);
      expect(_rect(tester, 'item').width, 400);
      size = tabletSize;
      sut = buildSut();
      setViewport(tester, size);
      await tester.pumpWidget(sut);
      expect(_rect(tester, 'item').width, 500);
    },
  );

  testWidgets('ajusta columnas fuera de rango y envuelve filas', (
    tester,
  ) async {
    child = const FFFlex(
      direction: FFValue.all(FFDirectionEnum.horizontal),
      gap: FFValue.all(10),
      children: [
        FFItem(
          col: FFValue.all(7),
          child: SizedBox(key: Key('a'), height: 10),
        ),
        FFItem(
          col: FFValue.all(7),
          child: SizedBox(key: Key('b'), height: 10),
        ),
        FFItem(
          col: FFValue.all(13),
          child: SizedBox(key: Key('c'), height: 10),
        ),
        FFItem(
          col: FFValue.all(0),
          child: SizedBox(key: Key('d'), height: 10),
        ),
      ],
    );
    sut = buildSut();
    setViewport(tester, size);
    await tester.pumpWidget(sut);
    expect(_rect(tester, 'b').top, greaterThan(_rect(tester, 'a').top));
    expect(_rect(tester, 'c').width, 400);
    expect(_rect(tester, 'd').width, closeTo(24.17, 0.01));
  });

  testWidgets('vertical reparte altura entre fill y alinea horizontalmente', (
    tester,
  ) async {
    child = const SizedBox.expand(
      child: FFFlex(
        direction: FFValue.all(FFDirectionEnum.vertical),
        gap: FFValue.all(10),
        crossAxisAlignment: FFValue.all(CrossAxisAlignment.center),
        children: [
          FFItem(
            fill: FFValue.all(false),
            child: SizedBox(key: Key('fixed'), width: 100, height: 40),
          ),
          FFItem(
            fill: FFValue.all(true),
            child: SizedBox(key: Key('fill'), width: 80),
          ),
        ],
      ),
    );
    sut = buildSut();
    setViewport(tester, size);
    await tester.pumpWidget(sut);
    expect(_rect(tester, 'fixed').left, 150);
    expect(_rect(tester, 'fill').left, 160);
    expect(_rect(tester, 'fill').height, 750);
  });

  testWidgets(
    'la columna sin límite de alto ignora fill y mantiene el alto natural',
    (tester) async {
      child = const SingleChildScrollView(
        child: FFFlex(
          direction: FFValue.all(FFDirectionEnum.vertical),
          children: [
            FFItem(
              fill: FFValue.all(true),
              child: SizedBox(key: Key('one'), height: 30),
            ),
            FFItem(
              fill: FFValue.all(true),
              child: SizedBox(key: Key('two'), height: 40),
            ),
          ],
        ),
      );
      sut = buildSut();
      setViewport(tester, size);
      await tester.pumpWidget(sut);
      expect(_rect(tester, 'one').height, 30);
      expect(_rect(tester, 'two').height, 40);
      expect(_rect(tester, 'two').top, _rect(tester, 'one').bottom);
    },
  );

  testWidgets(
    'alineación principal distribuye espacio y cross-axis estira filas',
    (tester) async {
      child = const SizedBox.expand(
        child: FFFlex(
          direction: FFValue.all(FFDirectionEnum.horizontal),
          mainAxisAlignment: FFValue.all(MainAxisAlignment.spaceBetween),
          crossAxisAlignment: FFValue.all(CrossAxisAlignment.stretch),
          children: [
            FFItem(
              fill: FFValue.all(false),
              child: SizedBox(key: Key('short'), width: 50, height: 20),
            ),
            FFItem(
              fill: FFValue.all(false),
              child: SizedBox(key: Key('tall'), width: 50, height: 40),
            ),
          ],
        ),
      );
      sut = buildSut();
      setViewport(tester, size);
      await tester.pumpWidget(sut);
      expect(_rect(tester, 'short').height, 40);
      expect(_rect(tester, 'tall').height, 40);
      expect(
        _rect(tester, 'tall').left,
        greaterThan(_rect(tester, 'short').right),
      );
    },
  );

  testWidgets('centra hijos en horizontal y respeta dirección RTL', (
    tester,
  ) async {
    child = const FFFlex(
      direction: FFValue.all(FFDirectionEnum.horizontalReverse),
      crossAxisAlignment: FFValue.all(CrossAxisAlignment.center),
      children: [
        FFItem(
          fill: FFValue.all(false),
          child: SizedBox(key: Key('a'), width: 80, height: 20),
        ),
        FFItem(
          fill: FFValue.all(false),
          child: SizedBox(key: Key('b'), width: 80, height: 40),
        ),
      ],
    );
    textDirection = TextDirection.rtl;
    sut = buildSut();
    setViewport(tester, size);
    await tester.pumpWidget(sut);
    expect(_rect(tester, 'a').left, lessThan(_rect(tester, 'b').left));
    expect(_rect(tester, 'a').top, _rect(tester, 'b').top + 10);
  });

  testWidgets('alineación mainAxis end y crossAxis end desplazan los hijos', (
    tester,
  ) async {
    child = const SizedBox.expand(
      child: FFFlex(
        direction: FFValue.all(FFDirectionEnum.vertical),
        mainAxisAlignment: FFValue.all(MainAxisAlignment.end),
        crossAxisAlignment: FFValue.all(CrossAxisAlignment.end),
        children: [
          FFItem(
            fill: FFValue.all(false),
            child: SizedBox(key: Key('child'), width: 50, height: 30),
          ),
        ],
      ),
    );
    sut = buildSut();
    setViewport(tester, size);
    await tester.pumpWidget(sut);
    expect(_rect(tester, 'child').right, 400);
    expect(_rect(tester, 'child').bottom, 800);
  });

  testWidgets('las reglas de orden actualizan el render sin perder estado', (
    tester,
  ) async {
    Widget buildFlex(int order) => FFFlex(
      children: [
        const FFItem(child: _Counter(key: Key('first'))),
        FFItem(
          order: FFValue.all(order),
          child: const _Counter(key: Key('second')),
        ),
      ],
    );
    child = buildFlex(0);
    sut = buildSut();
    setViewport(tester, size);
    await tester.pumpWidget(sut);
    tester.state<_CounterState>(find.byKey(const Key('second'))).value = 9;
    child = buildFlex(-1);
    sut = buildSut();
    await tester.pumpWidget(sut);
    expect(
      tester.state<_CounterState>(find.byKey(const Key('second'))).value,
      9,
    );
  });

  testWidgets('los getters de tamaño intrínseco funcionan en ambos ejes', (
    tester,
  ) async {
    child = const IntrinsicWidth(
      child: IntrinsicHeight(
        child: FFFlex(
          gap: FFValue.all(5),
          children: [
            SizedBox(width: 30, height: 20),
            SizedBox(width: 40, height: 10),
          ],
        ),
      ),
    );
    sut = buildSut();
    setViewport(tester, size);
    await tester.pumpWidget(sut);
    expect(tester.takeException(), isNull);
  });

  testWidgets('spaceAround y spaceEvenly separan los hijos de forma uniforme', (
    tester,
  ) async {
    const children = [
      FFItem(
        fill: FFValue.all(false),
        child: SizedBox(key: Key('first'), width: 40, height: 20),
      ),
      FFItem(
        fill: FFValue.all(false),
        child: SizedBox(key: Key('second'), width: 40, height: 20),
      ),
    ];
    child = const FFFlex(
      direction: FFValue.all(FFDirectionEnum.horizontal),
      mainAxisAlignment: FFValue.all(MainAxisAlignment.spaceAround),
      children: children,
    );
    sut = buildSut();
    setViewport(tester, size);
    await tester.pumpWidget(sut);
    final aroundGap =
        _rect(tester, 'second').left - _rect(tester, 'first').right;
    expect(_rect(tester, 'first').left, closeTo(80, 0.1));
    expect(aroundGap, closeTo(160, 0.1));

    child = const FFFlex(
      direction: FFValue.all(FFDirectionEnum.horizontal),
      mainAxisAlignment: FFValue.all(MainAxisAlignment.spaceEvenly),
      children: children,
    );
    sut = buildSut();
    await tester.pumpWidget(sut);
    expect(_rect(tester, 'first').left, closeTo(106.67, 0.1));
    expect(
      _rect(tester, 'second').left - _rect(tester, 'first').right,
      closeTo(106.67, 0.1),
    );
  });

  testWidgets('actualiza las propiedades de render al reconstruir el flex', (
    tester,
  ) async {
    Widget buildFlex({
      required FFDirectionEnum direction,
      required double gap,
      required MainAxisAlignment main,
      required CrossAxisAlignment cross,
    }) => SizedBox.expand(
      child: FFFlex(
        direction: FFValue.all(direction),
        gap: FFValue.all(gap),
        mainAxisAlignment: FFValue.all(main),
        crossAxisAlignment: FFValue.all(cross),
        children: const [
          FFItem(
            fill: FFValue.all(false),
            child: SizedBox(key: Key('first'), width: 60, height: 20),
          ),
          FFItem(
            fill: FFValue.all(false),
            child: SizedBox(key: Key('second'), width: 60, height: 20),
          ),
        ],
      ),
    );

    child = buildFlex(
      direction: FFDirectionEnum.horizontal,
      gap: 5,
      main: MainAxisAlignment.start,
      cross: CrossAxisAlignment.start,
    );
    sut = buildSut();
    setViewport(tester, size);
    await tester.pumpWidget(sut);
    child = buildFlex(
      direction: FFDirectionEnum.vertical,
      gap: 15,
      main: MainAxisAlignment.end,
      cross: CrossAxisAlignment.end,
    );
    textDirection = TextDirection.rtl;
    sut = buildSut();
    await tester.pumpWidget(sut);
    expect(_rect(tester, 'second').top, _rect(tester, 'first').bottom + 15);
    expect(_rect(tester, 'first').left, 0);
  });

  testWidgets('intrínsecos, baseline, hit testing y metadatos de slots', (
    tester,
  ) async {
    child = const Baseline(
      baseline: 24,
      baselineType: TextBaseline.alphabetic,
      child: FFFlex(
        key: Key('horizontal-flex'),
        direction: FFValue.all(FFDirectionEnum.horizontal),
        gap: FFValue.all(5),
        children: [
          FFItem(
            fill: FFValue.all(false),
            child: SizedBox(
              key: Key('first'),
              width: 30,
              height: 20,
              child: Text('A'),
            ),
          ),
          FFItem(
            fill: FFValue.all(false),
            child: SizedBox(
              key: Key('second'),
              width: 40,
              height: 10,
              child: Text('B'),
            ),
          ),
        ],
      ),
    );
    sut = buildSut();
    setViewport(tester, size);
    await tester.pumpWidget(sut);
    final layoutFinder = find.descendant(
      of: find.byKey(const Key('horizontal-flex')),
      matching: find.byWidgetPredicate(
        (widget) => widget.runtimeType.toString() == '_FFFlexLayout',
      ),
    );
    final render = tester.renderObject<RenderBox>(layoutFinder);
    expect(render.getMinIntrinsicWidth(100), 40);
    expect(render.getMaxIntrinsicWidth(100), 75);
    expect(render.getMinIntrinsicHeight(100), 20);
    expect(render.getMaxIntrinsicHeight(100), 20);
    final firstData =
        tester
                .renderObject<RenderBox>(find.byKey(const Key('first')))
                .parentData!
            as dynamic;
    final secondData =
        tester
                .renderObject<RenderBox>(find.byKey(const Key('second')))
                .parentData!
            as dynamic;
    expect(firstData.size, secondData.size);
    expect(firstData.size.hashCode, secondData.size.hashCode);
    final slot = tester.widget(
      find
          .byWidgetPredicate(
            (widget) => widget.runtimeType.toString() == '_FFSlot',
          )
          .first,
    ) as dynamic;
    expect(slot.debugTypicalAncestorWidgetClass.toString(), '_FFFlexLayout');

    var taps = 0;
    child = FFFlex(
      children: [
        GestureDetector(
          key: const Key('tap-target'),
          onTap: () => taps++,
          child: const SizedBox(width: 50, height: 30, child: Text('Tocar')),
        ),
      ],
    );
    sut = buildSut();
    await tester.pumpWidget(sut);
    await tester.tap(find.text('Tocar'));
    expect(taps, 1);
  });

  testWidgets('intrínsecos de columna toman ancho máximo y altos acumulados', (
    tester,
  ) async {
    child = const FFFlex(
      key: Key('vertical-flex'),
      direction: FFValue.all(FFDirectionEnum.vertical),
      gap: FFValue.all(5),
      children: [
        SizedBox(width: 30, height: 20),
        SizedBox(width: 40, height: 10),
      ],
    );
    sut = buildSut();
    setViewport(tester, size);
    await tester.pumpWidget(sut);
    final layoutFinder = find.descendant(
      of: find.byKey(const Key('vertical-flex')),
      matching: find.byWidgetPredicate(
        (widget) => widget.runtimeType.toString() == '_FFFlexLayout',
      ),
    );
    final render = tester.renderObject<RenderBox>(layoutFinder);
    expect(render.getMinIntrinsicWidth(100), 40);
    expect(render.getMaxIntrinsicWidth(100), 40);
    expect(render.getMinIntrinsicHeight(100), 35);
    expect(render.getMaxIntrinsicHeight(100), 35);
  });

  testWidgets('en columna, RTL desplaza un hijo hacia el lado derecho', (
    tester,
  ) async {
    child = const SizedBox(
      width: 400,
      child: FFFlex(
        direction: FFValue.all(FFDirectionEnum.vertical),
        crossAxisAlignment: FFValue.all(CrossAxisAlignment.start),
        children: [
          FFItem(
            fill: FFValue.all(false),
            child: SizedBox(key: Key('rtl-child'), width: 50, height: 20),
          ),
        ],
      ),
    );
    textDirection = TextDirection.rtl;
    sut = buildSut();
    setViewport(tester, size);
    await tester.pumpWidget(sut);
    expect(_rect(tester, 'rtl-child').right, 400);
  });

  testWidgets('un flex vacío tiene tamaño cero sin distribuir espacios', (
    tester,
  ) async {
    child = const FFFlex(children: []);
    sut = buildSut();
    setViewport(tester, size);
    await tester.pumpWidget(sut);
    expect(tester.getSize(find.byType(FFFlex)).height, 0);
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
  Widget build(BuildContext context) =>
      SizedBox(width: 40, height: 20, child: Text('$value'));
}
