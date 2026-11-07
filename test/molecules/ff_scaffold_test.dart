import 'package:flow_frame/flow_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _phone = Size(400, 800);
const _tablet = Size(1000, 800);
const _desktop = Size(1300, 800);
const _destinations = [
  FFDestination(id: 'home', icon: Icon(Icons.home), label: 'Inicio'),
  FFDestination(
    id: 'sales',
    icon: Icon(Icons.store),
    label: 'Ventas',
    children: [
      FFDestination(id: 'orders', icon: Icon(Icons.receipt), label: 'Pedidos'),
      FFDestination(id: 'clients', icon: Icon(Icons.people), label: 'Clientes'),
    ],
  ),
  FFDestination(
    id: 'reports',
    icon: Icon(Icons.bar_chart),
    label: 'Reportes',
    visible: FFValue(xs: false, md: true),
  ),
];

Future<void> _pump(
  WidgetTester tester, {
  required Size size,
  required GlobalKey<FFScaffoldState> key,
  String currentRoute = 'home',
  ValueChanged<String>? onRouteSelected,
  FFValue<FFNavStyle>? responsive,
  FFBrand? brand,
  PreferredSizeWidget? appBar,
  List<FFDestination> destinations = _destinations,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: FFScaffold(
        key: key,
        destinations: destinations,
        currentRoute: currentRoute,
        onRouteSelected: onRouteSelected ?? (_) {},
        responsive: responsive,
        brand: brand,
        appBar: appBar,
        floatingActionButton: const FloatingActionButton(
          onPressed: null,
          child: Icon(Icons.add),
        ),
        backgroundColor: Colors.white,
        body: const Text('contenido'),
      ),
    ),
  );
}

void main() {
  group('FFScaffold', () {
    testWidgets('aplica navegación responsive por defecto y expone acciones', (
      tester,
    ) async {
      // Arrange
      final key = GlobalKey<FFScaffoldState>();
      await _pump(tester, size: _phone, key: key);

      // Assert
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Reportes'), findsNothing);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('contenido'), findsOneWidget);

      // Act
      await _pump(tester, size: _tablet, key: key);

      // Assert
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.text('Reportes'), findsOneWidget);
      expect(key.currentState!.isMenuOpen, isFalse);
    });

    testWidgets('barra inferior enruta a hoja y resuelve grupo a subruta', (
      tester,
    ) async {
      // Arrange
      final key = GlobalKey<FFScaffoldState>();
      final selected = <String>[];
      await _pump(
        tester,
        size: _phone,
        key: key,
        onRouteSelected: selected.add,
      );

      // Act
      await tester.tap(find.text('Ventas'));

      // Assert
      expect(selected, ['orders']);

      // Act
      await tester.tap(find.text('Inicio'));

      // Assert
      expect(selected, ['orders', 'home']);
    });

    testWidgets('recuerda la última subruta de grupo cuando cambia ruta', (
      tester,
    ) async {
      // Arrange
      final key = GlobalKey<FFScaffoldState>();
      String? selected;
      await _pump(
        tester,
        size: _phone,
        key: key,
        currentRoute: 'clients',
        onRouteSelected: (id) => selected = id,
      );

      // Act
      await tester.tap(find.text('Ventas'));

      // Assert
      expect(selected, 'clients');
    });

    testWidgets(
      'el estado del rail controla abrir, cerrar y alternar overlay',
      (tester) async {
        // Arrange
        final key = GlobalKey<FFScaffoldState>();
        await _pump(tester, size: _tablet, key: key);

        // Assert
        expect(key.currentState!.isMenuOpen, isFalse);

        // Act
        key.currentState!.openMenu();
        await tester.pumpAndSettle();

        // Assert
        expect(key.currentState!.isMenuOpen, isTrue);
        expect(find.text('Inicio'), findsNWidgets(2));

        // Act
        key.currentState!.toggleMenu();
        await tester.pumpAndSettle();

        // Assert
        expect(key.currentState!.isMenuOpen, isFalse);

        // Act
        key.currentState!.toggleMenu();
        await tester.pumpAndSettle();
        key.currentState!.closeMenu();
        await tester.pumpAndSettle();

        // Assert
        expect(key.currentState!.isMenuOpen, isFalse);
      },
    );

    testWidgets('tocar el overlay cierra el menú y elegir un hijo enruta', (
      tester,
    ) async {
      // Arrange
      final key = GlobalKey<FFScaffoldState>();
      String? selected;
      await _pump(
        tester,
        size: _tablet,
        key: key,
        onRouteSelected: (id) => selected = id,
      );

      // Act
      key.currentState!.openMenu();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ventas').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clientes'));
      await tester.pumpAndSettle();

      // Assert
      expect(selected, 'clients');
      expect(key.currentState!.isMenuOpen, isFalse);
    });

    testWidgets(
      'la ruta actual abre su grupo y cambiar breakpoint reinicia overlay',
      (tester) async {
        // Arrange
        final key = GlobalKey<FFScaffoldState>();
        await _pump(tester, size: _tablet, key: key, currentRoute: 'orders');

        // Act
        key.currentState!.openMenu();
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Pedidos'), findsOneWidget);

        // Act
        await _pump(tester, size: _phone, key: key, currentRoute: 'orders');
        await _pump(tester, size: _tablet, key: key, currentRoute: 'orders');

        // Assert
        expect(key.currentState!.isMenuOpen, isFalse);
      },
    );

    testWidgets('drawer abre y se cierra al elegir una ruta', (tester) async {
      // Arrange
      final key = GlobalKey<FFScaffoldState>();
      String? selected;
      await _pump(
        tester,
        size: _phone,
        key: key,
        responsive: const FFValue(
          xs: FFNavStyle(type: FFNavigationEnum.drawer),
        ),
        onRouteSelected: (id) => selected = id,
      );

      // Assert
      expect(key.currentState!.isMenuOpen, isFalse);

      // Act
      key.currentState!.openMenu();
      await tester.pumpAndSettle();

      // Assert
      expect(key.currentState!.isMenuOpen, isTrue);

      // Act
      await tester.tap(find.text('Inicio').last);
      await tester.pumpAndSettle();

      // Assert
      expect(selected, 'home');
      expect(key.currentState!.isMenuOpen, isFalse);
    });

    testWidgets('sidebar inicia expandido, se contrae y conserva selección', (
      tester,
    ) async {
      // Arrange
      final key = GlobalKey<FFScaffoldState>();
      String? selected;
      await _pump(
        tester,
        size: _desktop,
        key: key,
        onRouteSelected: (id) => selected = id,
      );

      // Assert
      expect(key.currentState!.isMenuOpen, isTrue);
      expect(find.byTooltip('Cerrar menú'), findsOneWidget);

      // Act
      await tester.tap(find.byTooltip('Cerrar menú'));
      await tester.pumpAndSettle();

      // Assert
      expect(key.currentState!.isMenuOpen, isFalse);

      // Act
      await tester.tap(find.byTooltip('Abrir menú'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Inicio'));

      // Assert
      expect(selected, 'home');
      expect(key.currentState!.isMenuOpen, isTrue);
    });

    testWidgets('un grupo se expande y alwaysOpen prevalece sobre el estilo', (
      tester,
    ) async {
      // Arrange
      final key = GlobalKey<FFScaffoldState>();
      await _pump(
        tester,
        size: _tablet,
        key: key,
        responsive: const FFValue(
          xs: FFNavStyle(type: FFNavigationEnum.drawer),
          md: FFNavStyle(subRoutesAlwaysVisible: true),
        ),
        destinations: const [
          FFDestination(
            id: 'group',
            icon: Icon(Icons.folder),
            label: 'Grupo',
            children: [
              FFDestination(
                id: 'child',
                icon: Icon(Icons.insert_drive_file),
                label: 'Hijo',
              ),
            ],
          ),
        ],
      );

      // Act
      key.currentState!.openMenu();
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Hijo'), findsOneWidget);

      // Act
      await tester.tap(find.text('Grupo'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Hijo'), findsOneWidget);

      // Arrange
      await _pump(
        tester,
        size: _phone,
        key: key,
        responsive: const FFValue(
          xs: FFNavStyle(type: FFNavigationEnum.drawer),
        ),
        destinations: const [
          FFDestination(
            id: 'group',
            icon: Icon(Icons.folder),
            label: 'Grupo',
            alwaysOpen: true,
            children: [
              FFDestination(
                id: 'child',
                icon: Icon(Icons.insert_drive_file),
                label: 'Hijo',
              ),
            ],
          ),
        ],
      );

      // Act
      key.currentState!.openMenu();
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Hijo'), findsOneWidget);

      // Act
      await tester.tap(find.text('Grupo'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Hijo'), findsOneWidget);
    });

    testWidgets('appBar navigation keeps source app bar options and links', (
      tester,
    ) async {
      // Arrange
      final key = GlobalKey<FFScaffoldState>();
      String? selected;
      final source = AppBar(
        key: const Key('source-bar'),
        title: const Text('Sección'),
        backgroundColor: Colors.pink,
        centerTitle: true,
        actions: const [Icon(Icons.settings)],
      );
      await _pump(
        tester,
        size: _tablet,
        key: key,
        appBar: source,
        responsive: const FFValue(
          xs: FFNavStyle(type: FFNavigationEnum.appBar),
        ),
        onRouteSelected: (id) => selected = id,
      );

      // Assert
      final result = tester.widget<AppBar>(find.byKey(const Key('source-bar')));
      expect(result.centerTitle, isFalse);
      expect(result.backgroundColor, Colors.pink);
      expect(find.text('Inicio'), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);

      // Act
      await tester.tap(find.text('Inicio'));

      // Assert
      expect(selected, 'home');
    });

    testWidgets('FFAppBar recibe marca, enlaces y colores del scaffold', (
      tester,
    ) async {
      // Arrange
      final key = GlobalKey<FFScaffoldState>();
      await _pump(
        tester,
        size: _phone,
        key: key,
        brand: const FFBrand(title: Text('Marca')),
        appBar: const FFAppBar(),
        responsive: const FFValue(
          xs: FFNavStyle(
            type: FFNavigationEnum.appBar,
            backgroundColor: FFColor.fixed(Colors.teal),
            labelColor: FFColor.fixed(Colors.white),
          ),
        ),
      );

      // Assert
      expect(find.text('Marca'), findsOneWidget);
      expect(find.text('Inicio'), findsOneWidget);
      expect(
        tester.widget<AppBar>(find.byType(AppBar)).backgroundColor,
        Colors.teal,
      );
    });

    testWidgets('marca puede ir en título del app bar o en drawer', (
      tester,
    ) async {
      // Arrange
      final key = GlobalKey<FFScaffoldState>();
      await _pump(
        tester,
        size: _phone,
        key: key,
        brand: const FFBrand(
          logo: Icon(Icons.storefront),
          title: Text('Mi Tienda'),
          subtitle: Text('Panel'),
        ),
        appBar: AppBar(actions: const [Icon(Icons.search)], toolbarHeight: 72),
        responsive: const FFValue(
          xs: FFNavStyle(type: FFNavigationEnum.drawer),
        ),
      );

      // Assert
      expect(find.text('Mi Tienda'), findsOneWidget);
      expect(tester.widget<AppBar>(find.byType(AppBar)).toolbarHeight, 72);

      // Act
      key.currentState!.openMenu();
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Panel'), findsOneWidget);
    });

    testWidgets(
      'valores de estilos responsive se aplican sin decoraciones de sombra por defecto',
      (tester) async {
        // Arrange
        final key = GlobalKey<FFScaffoldState>();
        await _pump(
          tester,
          size: _phone,
          key: key,
          responsive: const FFValue(
            xs: FFNavStyle(
              type: FFNavigationEnum.bottom,
              shadow: true,
              backgroundColor: FFColor.fixed(Colors.black),
              selectedBackgroundColor: FFColor.fixed(Colors.orange),
              selectedIconColor: FFColor.fixed(Colors.red),
              selectedLabelColor: FFColor.fixed(Colors.blue),
              iconColor: FFColor.fixed(Colors.green),
              labelColor: FFColor.fixed(Colors.purple),
              shadowColor: FFColor.fixed(Colors.yellow),
            ),
          ),
        );

        // Assert
        expect(find.byType(DecoratedBox), findsWidgets);
        expect(
          tester
              .widget<NavigationBar>(find.byType(NavigationBar))
              .backgroundColor,
          Colors.black,
        );

        // Act
        await _pump(tester, size: _phone, key: key);

        // Assert
        final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
        expect(bar.backgroundColor, isNull);
      },
    );

    testWidgets('estilo de rail define colores de iconos y etiquetas', (
      tester,
    ) async {
      // Arrange
      final key = GlobalKey<FFScaffoldState>();
      await _pump(
        tester,
        size: _tablet,
        key: key,
        currentRoute: 'home',
        responsive: const FFValue(
          xs: FFNavStyle(
            type: FFNavigationEnum.rail,
            expandMode: FFRailExpandEnum.overlay,
            labelColor: FFColor.fixed(Colors.green),
            selectedLabelColor: FFColor.fixed(Colors.orange),
            iconColor: FFColor.fixed(Colors.blue),
            selectedIconColor: FFColor.fixed(Colors.red),
            selectedBackgroundColor: FFColor.fixed(Colors.black12),
          ),
        ),
      );

      // Assert
      final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.unselectedLabelTextStyle!.color, Colors.green);
      expect(rail.selectedLabelTextStyle!.color, Colors.orange);
      expect(rail.unselectedIconTheme!.color, Colors.blue);
      expect(rail.selectedIconTheme!.color, Colors.red);
      expect(rail.indicatorColor, Colors.black12);
      expect(rail.selectedIndex, 0);
    });

    testWidgets(
      'drawer sin brand, y appbar links en PreferredSize personalizado',
      (tester) async {
        // Arrange
        final key = GlobalKey<FFScaffoldState>();
        const responsive = FFValue(
          xs: FFNavStyle(type: FFNavigationEnum.appBar),
        );
        final customBar = PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: const ColoredBox(
            color: Colors.amber,
            child: SizedBox(height: 40),
          ),
        );
        await _pump(
          tester,
          size: _phone,
          key: key,
          appBar: customBar,
          responsive: responsive,
        );

        // Assert
        expect(find.text('Inicio'), findsOneWidget);
        expect(tester.getTopLeft(find.text('Inicio')).dy, greaterThan(40));
      },
    );
  });
}
