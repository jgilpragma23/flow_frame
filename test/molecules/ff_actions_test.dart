import 'package:flow_frame/flow_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Size size;
  late Size phoneSize;
  late Size tabletSize;
  late List<FFAction> actions;
  late Widget menuIcon;
  late String menuTooltip;
  late Widget sut;
  late int presses;
  late String selected;
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
    actions = [];
    menuIcon = Icon(Icons.more_vert);
    menuTooltip = 'Más opciones';
    presses = 0;
    selected = '';
    buildSut = () => MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          actions: [
            FFActions(
              actions: actions,
              menuIcon: menuIcon,
              menuTooltip: menuTooltip,
            ),
          ],
        ),
      ),
    );
    sut = buildSut();
  });

  testWidgets('usa solo iconos por defecto y llama a la acción', (
    tester,
  ) async {
    // Arrange
    actions = [
      FFAction(
        icon: const Icon(Icons.add),
        label: 'Crear',
        onPressed: () => presses++,
      ),
    ];
    sut = buildSut();
    setViewport(tester, size);

    // Act
    await tester.pumpWidget(sut);

    // Assert
    expect(find.byTooltip('Crear'), findsOneWidget);
    expect(find.text('Crear'), findsNothing);
    await tester.tap(find.byTooltip('Crear'));
    expect(presses, 1);
  });

  testWidgets('muestra la acción completa en el breakpoint vigente', (
    tester,
  ) async {
    // Arrange
    size = tabletSize;
    actions = [
      const FFAction(
        icon: Icon(Icons.save),
        label: 'Guardar',
        display: FFValue(
          xs: FFActionDisplayEnum.icon,
          md: FFActionDisplayEnum.full,
        ),
      ),
    ];
    sut = buildSut();
    setViewport(tester, size);

    // Act
    await tester.pumpWidget(sut);

    // Assert
    expect(find.text('Guardar'), findsOneWidget);
    expect(find.byType(TextButton), findsOneWidget);
    expect(find.byTooltip('Guardar'), findsNothing);
  });

  testWidgets('resuelve en cascada y muestra solo las acciones de menú', (
    tester,
  ) async {
    // Arrange
    menuIcon = const Icon(Icons.more_horiz);
    menuTooltip = 'Acciones';
    actions = [
      FFAction(
        icon: const Icon(Icons.edit),
        label: 'Editar',
        display: const FFValue(xs: FFActionDisplayEnum.menu, md: null),
        onPressed: () => selected = 'Editar',
      ),
      FFAction(
        icon: const Icon(Icons.delete),
        label: 'Eliminar',
        display: const FFValue.all(FFActionDisplayEnum.menu),
        onPressed: () => selected = 'Eliminar',
      ),
      const FFAction(
        icon: Icon(Icons.archive),
        label: 'Archivar',
        display: FFValue.all(FFActionDisplayEnum.hidden),
      ),
    ];
    sut = buildSut();
    setViewport(tester, size);

    // Act
    await tester.pumpWidget(sut);
    await tester.tap(find.byTooltip('Acciones'));
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Editar'), findsOneWidget);
    expect(find.text('Eliminar'), findsOneWidget);
    expect(find.text('Archivar'), findsNothing);
    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();
    expect(selected, 'Eliminar');
  });

  testWidgets('no crea el menú si no hay acciones asignadas a él', (
    tester,
  ) async {
    // Arrange
    actions = [
      const FFAction(
        icon: Icon(Icons.visibility_off),
        label: 'Oculta',
        display: FFValue.all(FFActionDisplayEnum.hidden),
      ),
    ];
    sut = buildSut();
    setViewport(tester, size);

    // Act
    await tester.pumpWidget(sut);

    // Assert
    expect(find.byTooltip(menuTooltip), findsNothing);
    expect(find.byIcon(Icons.visibility_off), findsNothing);
  });

  testWidgets('un botón de menú puede abrirse y cerrarse de nuevo', (
    tester,
  ) async {
    // Arrange
    actions = [
      const FFAction(
        icon: Icon(Icons.share),
        label: 'Compartir',
        display: FFValue.all(FFActionDisplayEnum.menu),
      ),
    ];
    sut = buildSut();
    setViewport(tester, size);

    // Act
    await tester.pumpWidget(sut);
    final menuButton = find.byTooltip(menuTooltip);
    await tester.tap(menuButton);
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Compartir'), findsOneWidget);
    await tester.tap(menuButton);
    await tester.pumpAndSettle();
    expect(find.text('Compartir'), findsNothing);
  });

  testWidgets('un callback nulo deja la acción deshabilitada', (tester) async {
    // Arrange
    size = tabletSize;
    actions = [
      const FFAction(
        icon: Icon(Icons.lock),
        label: 'Bloqueada',
        display: FFValue.all(FFActionDisplayEnum.full),
      ),
    ];
    sut = buildSut();
    setViewport(tester, size);

    // Act
    await tester.pumpWidget(sut);

    // Assert
    final button = tester.widget<TextButton>(find.byType(TextButton));
    expect(button.onPressed, isNull);
  });
}
