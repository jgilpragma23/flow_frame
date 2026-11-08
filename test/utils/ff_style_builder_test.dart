import 'package:flow_frame/flow_frame.dart';
import 'package:flow_frame/src/utils/ff_style_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _child = SizedBox(key: Key('style-child'), width: 20, height: 10);

Future<void> _pumpStyle(
  WidgetTester tester,
  FFStyle? style, {
  Size size = const Size(800, 600),
  Widget child = _child,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    Directionality(
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
    ),
  );
}

Finder _ancestorOfChild(Type type) => find.ancestor(
  of: find.byKey(const Key('style-child')),
  matching: find.byType(type),
);

void main() {
  group('buildFFStyle', () {
    testWidgets('devuelve el hijo cuando no hay estilo', (tester) async {
      await _pumpStyle(tester, null);

      expect(find.byKey(const Key('style-child')), findsOneWidget);
      expect(find.byType(Padding), findsNothing);
      expect(find.byType(ColoredBox), findsNothing);
    });

    testWidgets('oculta el hijo cuando visible es false', (tester) async {
      await _pumpStyle(tester, const FFStyle(visible: FFValue.all(false)));

      expect(find.byKey(const Key('style-child')), findsNothing);
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('aplica texto, alineación y padding', (tester) async {
      await _pumpStyle(
        tester,
        const FFStyle(
          textStyle: FFValue.all(TextStyle(fontWeight: FontWeight.bold)),
          textAlign: FFValue.all(TextAlign.center),
          padding: FFSpacing(all: FFValue.all(8)),
        ),
      );

      final defaultTextStyle = tester.widget<DefaultTextStyle>(
        _ancestorOfChild(DefaultTextStyle),
      );
      final padding = tester.widget<Padding>(_ancestorOfChild(Padding));

      expect(defaultTextStyle.style.fontWeight, FontWeight.bold);
      expect(defaultTextStyle.textAlign, TextAlign.center);
      expect(padding.padding, const EdgeInsets.all(8));
    });

    testWidgets('recorta el contenido cuando clip está habilitado', (
      tester,
    ) async {
      await _pumpStyle(tester, const FFStyle(clip: FFValue.all(true)));

      final clip = tester.widget<UnconstrainedBox>(
        _ancestorOfChild(UnconstrainedBox),
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
      await _pumpStyle(
        tester,
        const FFStyle(
          borderRadius: FFValue.all(radius),
          borderWidth: FFValue.all(4),
          borderColor: FFColor.fixed(Colors.red),
        ),
      );

      final clip = tester.widget<ClipRRect>(_ancestorOfChild(ClipRRect));
      final decoration = tester.widget<DecoratedBox>(
        _ancestorOfChild(DecoratedBox),
      );
      final borderPadding = tester.widgetList<Padding>(
        _ancestorOfChild(Padding),
      );
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

      for (final style in scenarios) {
        await _pumpStyle(tester, style);

        expect(_ancestorOfChild(DecoratedBox), findsOneWidget);
        expect(_ancestorOfChild(ColoredBox), findsNothing);
      }
    });

    testWidgets('usa ColoredBox para un fondo sin decoración adicional', (
      tester,
    ) async {
      await _pumpStyle(
        tester,
        const FFStyle(
          backgroundColor: FFValue.all(FFColor.fixed(Colors.green)),
        ),
      );

      final coloredBox = tester.widget<ColoredBox>(
        _ancestorOfChild(ColoredBox),
      );
      expect(coloredBox.color, Colors.green);
      expect(_ancestorOfChild(DecoratedBox), findsNothing);
    });

    testWidgets('establece ancho y alto cuando están definidos', (
      tester,
    ) async {
      await _pumpStyle(
        tester,
        const FFStyle(width: FFValue.all(100), height: FFValue.all(50)),
      );

      final sizedBox = tester.widget<SizedBox>(_ancestorOfChild(SizedBox));
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
        await _pumpStyle(tester, scenarios[i]);

        final constrainedBox = tester.widget<ConstrainedBox>(
          _ancestorOfChild(ConstrainedBox),
        );
        expect(constrainedBox.constraints, expected[i]);
      }
    });

    testWidgets('aplica margin como padding exterior', (tester) async {
      await _pumpStyle(
        tester,
        const FFStyle(margin: FFSpacing(all: FFValue.all(12))),
      );

      final padding = tester.widget<Padding>(_ancestorOfChild(Padding));
      expect(padding.padding, const EdgeInsets.all(12));
    });
  });
}
