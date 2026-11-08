import 'package:flow_frame/flow_frame.dart';
import 'package:flow_frame/src/utils/ff_style_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Size size;
  late FFStyle? style;
  late Widget child;
  late Widget sut;
  late Widget Function() buildSut;

  void setViewport(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  setUp(() {
    size = Size(800, 600);
    style = null;
    child = SizedBox(key: Key('style-child'), width: 20, height: 10);
    buildSut = () => Directionality(
      textDirection: TextDirection.ltr,
      child: MediaQuery(
        data: MediaQueryData(size: size),
        child: Theme(
          data: ThemeData(),
          child: Builder(
            builder: (context) => buildFFStyle(context, style, child),
          ),
        ),
      ),
    );
    sut = buildSut();
  });

  Finder ancestorOfChild(Type type) => find.ancestor(
    of: find.byKey(const Key('style-child')),
    matching: find.byType(type),
  );

  testWidgets('devuelve el hijo cuando no hay estilo', (tester) async {
    setViewport(tester, size);
    await tester.pumpWidget(sut);

    expect(find.byKey(const Key('style-child')), findsOneWidget);
    expect(find.byType(Padding), findsNothing);
    expect(find.byType(ColoredBox), findsNothing);
  });

  testWidgets('oculta el hijo cuando visible es false', (tester) async {
    style = const FFStyle(visible: FFValue.all(false));
    sut = buildSut();
    setViewport(tester, size);
    await tester.pumpWidget(sut);

    expect(find.byKey(const Key('style-child')), findsNothing);
    expect(find.byType(SizedBox), findsOneWidget);
  });

  testWidgets('aplica texto, alineación y padding', (tester) async {
    style = const FFStyle(
      textStyle: FFValue.all(TextStyle(fontWeight: FontWeight.bold)),
      textAlign: FFValue.all(TextAlign.center),
      padding: FFSpacing(all: FFValue.all(8)),
    );
    sut = buildSut();
    setViewport(tester, size);
    await tester.pumpWidget(sut);

    final defaultTextStyle = tester.widget<DefaultTextStyle>(
      ancestorOfChild(DefaultTextStyle),
    );
    final padding = tester.widget<Padding>(ancestorOfChild(Padding));

    expect(defaultTextStyle.style.fontWeight, FontWeight.bold);
    expect(defaultTextStyle.textAlign, TextAlign.center);
    expect(padding.padding, const EdgeInsets.all(8));
  });

  testWidgets('recorta el contenido cuando clip está habilitado', (
    tester,
  ) async {
    style = const FFStyle(clip: FFValue.all(true));
    sut = buildSut();
    setViewport(tester, size);
    await tester.pumpWidget(sut);

    final clip = tester.widget<UnconstrainedBox>(
      ancestorOfChild(UnconstrainedBox),
    );
    expect(clip.constrainedAxis, Axis.horizontal);
    expect(clip.alignment, AlignmentDirectional.topStart);
    expect(clip.clipBehavior, Clip.hardEdge);
  });

  testWidgets('reduce por separado los radios interiores del borde', (
    tester,
  ) async {
    const radius = BorderRadius.only(
      topLeft: Radius.elliptical(8, 3),
      topRight: Radius.elliptical(2, 9),
      bottomLeft: Radius.elliptical(5, 6),
      bottomRight: Radius.elliptical(1, 1),
    );
    style = const FFStyle(
      borderRadius: FFValue.all(radius),
      borderWidth: FFValue.all(4),
      borderColor: FFColor.fixed(Colors.red),
    );
    sut = buildSut();
    setViewport(tester, size);
    await tester.pumpWidget(sut);

    final clip = tester.widget<ClipRRect>(ancestorOfChild(ClipRRect));
    final decoration = tester.widget<DecoratedBox>(
      ancestorOfChild(DecoratedBox),
    );
    final borderPadding = tester.widgetList<Padding>(ancestorOfChild(Padding));
    final border = (decoration.decoration as BoxDecoration).border!;

    expect(
      clip.borderRadius,
      const BorderRadius.only(
        topLeft: Radius.elliptical(4, 0),
        topRight: Radius.elliptical(0, 5),
        bottomLeft: Radius.elliptical(1, 2),
        bottomRight: Radius.elliptical(0, 0),
      ),
    );
    expect(border.top.width, 4);
    expect(border.top.color, Colors.red);
    expect(borderPadding.first.padding, const EdgeInsets.all(4));
  });

  testWidgets('usa DecoratedBox para fondo, sombra y solo borde redondeado', (
    tester,
  ) async {
    final scenarios = <FFStyle>[
      const FFStyle(
        backgroundColor: FFValue.all(FFColor.fixed(Colors.blue)),
        shadow: FFValue.all(FFShadow.sm),
      ),
      const FFStyle(
        borderRadius: FFValue.all(BorderRadius.all(Radius.circular(6))),
      ),
    ];

    for (final scenario in scenarios) {
      style = scenario;
      sut = buildSut();
      setViewport(tester, size);
      await tester.pumpWidget(sut);

      expect(ancestorOfChild(DecoratedBox), findsOneWidget);
      expect(ancestorOfChild(ColoredBox), findsNothing);
    }
  });

  testWidgets('usa ColoredBox para un fondo sin decoración adicional', (
    tester,
  ) async {
    style = const FFStyle(
      backgroundColor: FFValue.all(FFColor.fixed(Colors.green)),
    );
    sut = buildSut();
    setViewport(tester, size);
    await tester.pumpWidget(sut);

    final coloredBox = tester.widget<ColoredBox>(ancestorOfChild(ColoredBox));
    expect(coloredBox.color, Colors.green);
    expect(ancestorOfChild(DecoratedBox), findsNothing);
  });

  testWidgets('establece ancho y alto cuando están definidos', (tester) async {
    style = const FFStyle(width: FFValue.all(100), height: FFValue.all(50));
    sut = buildSut();
    setViewport(tester, size);
    await tester.pumpWidget(sut);

    final sizedBox = tester.widget<SizedBox>(ancestorOfChild(SizedBox));
    expect(sizedBox.width, 100);
    expect(sizedBox.height, 50);
  });

  testWidgets('aplica cada límite de ancho y alto', (tester) async {
    const scenarios = <FFStyle>[
      FFStyle(minWidth: FFValue.all(10)),
      FFStyle(maxWidth: FFValue.all(90)),
      FFStyle(maxHeight: FFValue.all(40)),
    ];
    const expected = <BoxConstraints>[
      BoxConstraints(minWidth: 10),
      BoxConstraints(maxWidth: 90),
      BoxConstraints(maxHeight: 40),
    ];

    for (var i = 0; i < scenarios.length; i++) {
      style = scenarios[i];
      sut = buildSut();
      setViewport(tester, size);
      await tester.pumpWidget(sut);

      final constrainedBox = tester.widget<ConstrainedBox>(
        ancestorOfChild(ConstrainedBox),
      );
      expect(constrainedBox.constraints, expected[i]);
    }
  });

  testWidgets('aplica margin como padding exterior', (tester) async {
    style = const FFStyle(margin: FFSpacing(all: FFValue.all(12)));
    sut = buildSut();
    setViewport(tester, size);
    await tester.pumpWidget(sut);

    final padding = tester.widget<Padding>(ancestorOfChild(Padding));
    expect(padding.padding, const EdgeInsets.all(12));
  });
}
