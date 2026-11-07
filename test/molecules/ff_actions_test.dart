import 'package:flow_frame/flow_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _phone = Size(400, 800);
const _tablet = Size(1000, 800);

Future<void> _pump(
  WidgetTester tester, {
  required Size size,
  required List<FFAction> actions,
  Widget? menuIcon,
  String menuTooltip = 'Más opciones',
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          actions: [
            FFActions(
              actions: actions,
              menuIcon: menuIcon ?? const Icon(Icons.more_vert),
              menuTooltip: menuTooltip,
            ),
          ],
        ),
      ),
    ),
  );
}

void main() {
  group('FFActions', () {
    testWidgets('usa solo iconos por defecto y llama a la acción', (
      tester,
    ) async {
      var presses = 0;
      await _pump(
        tester,
        size: _phone,
        actions: [
          FFAction(
            icon: const Icon(Icons.add),
            label: 'Crear',
            onPressed: () => presses++,
          ),
        ],
      );

      expect(find.byTooltip('Crear'), findsOneWidget);
      expect(find.text('Crear'), findsNothing);
      await tester.tap(find.byTooltip('Crear'));
      expect(presses, 1);
    });

    testWidgets('muestra la acción completa en el breakpoint vigente', (
      tester,
    ) async {
      await _pump(
        tester,
        size: _tablet,
        actions: [
          FFAction(
            icon: const Icon(Icons.save),
            label: 'Guardar',
            display: const FFValue(
              xs: FFActionDisplayEnum.icon,
              md: FFActionDisplayEnum.full,
            ),
          ),
        ],
      );

      expect(find.text('Guardar'), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
      expect(find.byTooltip('Guardar'), findsNothing);
    });

    testWidgets('resuelve en cascada y muestra solo las acciones de menú', (
      tester,
    ) async {
      var selected = '';
      await _pump(
        tester,
        size: _phone,
        menuIcon: const Icon(Icons.more_horiz),
        menuTooltip: 'Acciones',
        actions: [
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
          FFAction(
            icon: const Icon(Icons.archive),
            label: 'Archivar',
            display: const FFValue.all(FFActionDisplayEnum.hidden),
          ),
        ],
      );

      await tester.tap(find.byTooltip('Acciones'));
      await tester.pumpAndSettle();
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
      await _pump(
        tester,
        size: _phone,
        actions: [
          const FFAction(
            icon: Icon(Icons.visibility_off),
            label: 'Oculta',
            display: FFValue.all(FFActionDisplayEnum.hidden),
          ),
        ],
      );

      expect(find.byTooltip('Más opciones'), findsNothing);
      expect(find.byIcon(Icons.visibility_off), findsNothing);
    });

    testWidgets('un botón de menú puede abrirse y cerrarse de nuevo', (
      tester,
    ) async {
      await _pump(
        tester,
        size: _phone,
        actions: [
          const FFAction(
            icon: Icon(Icons.share),
            label: 'Compartir',
            display: FFValue.all(FFActionDisplayEnum.menu),
          ),
        ],
      );

      final menuButton = find.byTooltip('Más opciones');
      await tester.tap(menuButton);
      await tester.pumpAndSettle();
      expect(find.text('Compartir'), findsOneWidget);
      await tester.tap(menuButton);
      await tester.pumpAndSettle();
      expect(find.text('Compartir'), findsNothing);
    });

    testWidgets('un callback nulo deja la acción deshabilitada', (
      tester,
    ) async {
      await _pump(
        tester,
        size: _tablet,
        actions: [
          const FFAction(
            icon: Icon(Icons.lock),
            label: 'Bloqueada',
            display: FFValue.all(FFActionDisplayEnum.full),
          ),
        ],
      );

      final button = tester.widget<TextButton>(find.byType(TextButton));
      expect(button.onPressed, isNull);
    });
  });
}
