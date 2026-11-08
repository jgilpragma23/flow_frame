import 'package:flow_frame/flow_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Finder _containerAlign() => find.ancestor(
  of: find.byKey(const Key('container-child')),
  matching: find.byType(Align),
);

void main() {
  late SizedBox child;
  late FFContainer fullWidthContainer;
  late FFContainer constrainedContainer;
  late FFContainer Function() invalidContainer;
  late Widget sut;

  setUp(() {
    child = const SizedBox(key: Key('container-child'), height: 20);
    fullWidthContainer = FFContainer(child: child);
    constrainedContainer = FFContainer(
      maxSize: 360,
      style: const FFStyle(maxWidth: FFValue.all(240)),
      child: child,
    );
    invalidContainer = () => FFContainer(maxSize: 0, child: child);
    sut = MaterialApp(home: Scaffold(body: fullWidthContainer));
  });

  testWidgets('sin maxSize ocupa el ancho disponible y se centra arriba', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    // Act
    await tester.pumpWidget(sut);

    // Assert
    final align = tester.widget<Align>(_containerAlign());
    final childRect = tester.getRect(find.byKey(const Key('container-child')));
    expect(align.alignment, Alignment.topCenter);
    expect(align.heightFactor, 1);
    expect(childRect.width, 800);
    expect(childRect.top, 0);
  });

  testWidgets('limita el ancho y aplica el maxWidth del estilo', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    sut = MaterialApp(home: Scaffold(body: constrainedContainer));

    // Act
    await tester.pumpWidget(sut);

    // Assert
    final constraints = tester
        .widgetList<ConstrainedBox>(
          find.ancestor(
            of: find.byKey(const Key('container-child')),
            matching: find.byType(ConstrainedBox),
          ),
        )
        .map((box) => box.constraints.maxWidth);
    expect(constraints, containsAll(<double>[360, 240]));
    expect(tester.getRect(find.byKey(const Key('container-child'))).width, 240);
  });

  test('rechaza un maxSize no positivo', () {
    // Assert
    expect(invalidContainer, throwsAssertionError);
  });
}
