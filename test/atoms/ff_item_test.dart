import 'package:flow_frame/flow_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Finder _ancestorsOfChild(Type type) => find.ancestor(
  of: find.byKey(const Key('item-child')),
  matching: find.byType(type),
);

void main() {
  late SizedBox child;
  late FFItem plainItem;
  late FFStyledItem styledItem;
  late FFStyledItem responsiveWidthItem;
  late FFStyledItem maxWidthItem;
  late Widget sut;

  setUp(() {
    child = const SizedBox(key: Key('item-child'), width: 40, height: 20);
    plainItem = FFItem(child: child);
    styledItem = FFStyledItem(
      style: const FFStyle(
        backgroundColor: FFValue.all(FFColor.fixed(Colors.blue)),
        padding: FFSpacing(all: FFValue.all(8)),
      ),
      col: const FFValue.all(6),
      fill: const FFValue.all(true),
      order: const FFValue.all(1),
      child: child,
    );
    responsiveWidthItem = FFStyledItem(
      style: const FFStyle(width: FFValue(xs: 120, md: 240)),
      child: child,
    );
    maxWidthItem = FFStyledItem(
      style: const FFStyle(maxWidth: FFValue.all(180)),
      child: child,
    );
    sut = MaterialApp(home: Scaffold(body: plainItem));
  });

  testWidgets('sin estilo presenta el hijo directamente', (tester) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    // Act
    await tester.pumpWidget(sut);

    // Assert
    expect(find.byKey(const Key('item-child')), findsOneWidget);
    expect(_ancestorsOfChild(Align), findsNothing);
  });

  testWidgets('aplica el estilo sin límites de ancho sin envolver en Align', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    sut = MaterialApp(home: Scaffold(body: styledItem));

    // Act
    await tester.pumpWidget(sut);

    // Assert
    expect(_ancestorsOfChild(Align), findsNothing);
    final colors = tester
        .widgetList<ColoredBox>(_ancestorsOfChild(ColoredBox))
        .map((box) => box.color);
    expect(colors, contains(Colors.blue));
    expect(_ancestorsOfChild(Padding), findsOneWidget);
  });

  testWidgets('un width responsive suelta las restricciones de la columna', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    sut = MaterialApp(home: Scaffold(body: responsiveWidthItem));

    // Act
    await tester.pumpWidget(sut);

    // Assert
    final align = tester.widget<Align>(_ancestorsOfChild(Align));
    final widths = tester
        .widgetList<SizedBox>(_ancestorsOfChild(SizedBox))
        .map((box) => box.width);
    expect(align.alignment, AlignmentDirectional.topStart);
    expect(align.heightFactor, 1);
    expect(widths, contains(240));
    expect(widths, contains(double.infinity));
  });

  testWidgets('maxWidth también activa el wrapper de ancho flexible', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    sut = MaterialApp(home: Scaffold(body: maxWidthItem));

    // Act
    await tester.pumpWidget(sut);

    // Assert
    expect(_ancestorsOfChild(Align), findsOneWidget);
    final constraints = tester
        .widgetList<ConstrainedBox>(_ancestorsOfChild(ConstrainedBox))
        .map((box) => box.constraints.maxWidth);
    expect(constraints, contains(180));
  });
}
