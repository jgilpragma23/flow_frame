import 'package:flow_frame/flow_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Size size;
  late PreferredSizeWidget appBar;
  late ThemeData? theme;
  late Widget sut;
  late Widget Function() buildSut;
  late List<FFDestination> destinations;
  late Size phoneSize;
  late Size wideSize;
  late FFBrand brand;

  void setViewport(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  setUp(() {
    phoneSize = Size(400, 800);
    wideSize = Size(1200, 800);
    brand = FFBrand(
      logo: Icon(Icons.store),
      title: Text('Tienda'),
      subtitle: Text('Administración'),
    );
    size = phoneSize;
    appBar = const FFAppBar();
    theme = null;
    buildSut = () => MaterialApp(
      theme: theme,
      home: Scaffold(appBar: appBar, body: const Text('contenido')),
    );
    sut = buildSut();
    destinations = [
      FFDestination(id: 'home', icon: Icon(Icons.home), label: 'Inicio'),
      FFDestination(
        id: 'group',
        icon: Icon(Icons.folder),
        label: 'Gestión',
        children: [
          FFDestination(
            id: 'orders',
            icon: Icon(Icons.receipt),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Pedidos',
            visible: FFValue(xs: false, md: true),
          ),
          FFDestination(
            id: 'users',
            icon: Icon(Icons.people),
            label: 'Usuarios',
          ),
        ],
      ),
      FFDestination(
        id: 'hidden',
        icon: Icon(Icons.visibility_off),
        label: 'Oculto',
        visible: FFValue(xs: false),
      ),
      FFDestination(
        id: 'empty',
        icon: Icon(Icons.folder_off),
        label: 'Grupo vacío',
        children: [
          FFDestination(
            id: 'unavailable',
            icon: Icon(Icons.block),
            label: 'No disponible',
            visible: FFValue(xs: false),
          ),
        ],
      ),
    ];
  });

  test('preferredSize incluye toolbar y bottom custom', () {
    final bar = FFAppBar(
      toolbarHeight: 64,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(20),
        child: const SizedBox(height: 20),
      ),
    );
    expect(bar.preferredSize, const Size.fromHeight(84));
  });

  test('copyWith conserva campos no reemplazados y aplica reemplazos', () {
    final bar = FFAppBar(
      key: const Key('app-bar'),
      brand: brand,
      title: const Text('Original'),
      destinations: destinations,
      currentRoute: 'home',
      onRouteSelected: (_) {},
      toolbarHeight: 60,
    );
    final copy = bar.copyWith(title: const Text('Copia'));

    expect(copy.key, bar.key);
    expect(copy.title, isA<Text>());
    expect(copy.brand, same(brand));
    expect(copy.destinations, same(destinations));
    expect(copy.currentRoute, 'home');
    expect(copy.toolbarHeight, 60);
    expect(copy.automaticallyImplyLeading, isTrue);
  });

  testWidgets('compone marca y título con separación y respeta leading', (
    tester,
  ) async {
    appBar = FFAppBar(
      brand: brand,
      title: Text('Pedidos'),
      leading: Icon(Icons.arrow_back),
      automaticallyImplyLeading: false,
    );
    sut = buildSut();
    setViewport(tester, size);
    await tester.pumpWidget(sut);

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('Tienda'), findsOneWidget);
    expect(find.text('Pedidos'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    expect(
      tester.widget<AppBar>(find.byType(AppBar)).automaticallyImplyLeading,
      isFalse,
    );
  });

  testWidgets('brand, title y centerTitle cambian por breakpoint', (
    tester,
  ) async {
    final FFAppBar bar = FFAppBar(
      brand: brand,
      title: Text('Pedidos'),
      responsive: FFValue(
        xs: FFAppBarStyle(centerTitle: true, showBrand: false),
        md: FFAppBarStyle(showTitle: false, showBrand: true),
      ),
    );
    size = phoneSize;
    appBar = bar;
    sut = buildSut();
    setViewport(tester, size);
    await tester.pumpWidget(sut);
    expect(find.text('Tienda'), findsNothing);
    expect(find.text('Pedidos'), findsOneWidget);
    expect(tester.widget<AppBar>(find.byType(AppBar)).centerTitle, isTrue);

    size = wideSize;
    sut = buildSut();
    setViewport(tester, size);
    await tester.pumpWidget(sut);
    expect(find.text('Tienda'), findsOneWidget);
    expect(find.text('Pedidos'), findsNothing);
  });

  testWidgets('visible false reemplaza el app bar por espacio de status bar', (
    tester,
  ) async {
    const bar = FFAppBar(
      title: Text('Oculta'),
      responsive: FFValue(xs: FFAppBarStyle(visible: false)),
    );
    size = phoneSize;
    appBar = bar;
    sut = buildSut();
    setViewport(tester, size);
    await tester.pumpWidget(sut);
    expect(find.byType(AppBar), findsNothing);
    expect(find.text('Oculta'), findsNothing);
    expect(tester.getTopLeft(find.text('contenido')).dy, 0);
  });

  testWidgets('omite destinos ocultos y grupos sin hijos visibles', (
    tester,
  ) async {
    String? route;
    appBar = FFAppBar(
      destinations: destinations,
      onRouteSelected: (id) => route = id,
    );
    size = phoneSize;
    sut = buildSut();
    setViewport(tester, size);
    await tester.pumpWidget(sut);
    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Gestión'), findsOneWidget);
    expect(find.text('Oculto'), findsNothing);
    expect(find.text('Grupo vacío'), findsNothing);

    await tester.tap(find.text('Inicio'));
    expect(route, 'home');
  });

  testWidgets(
    'no muestra enlaces sin callback; filtra enlaces por breakpoint',
    (tester) async {
      size = phoneSize;
      appBar = FFAppBar(destinations: destinations);
      sut = buildSut();
      setViewport(tester, size);
      await tester.pumpWidget(sut);
      expect(find.text('Inicio'), findsNothing);

      String? route;
      size = wideSize;
      appBar = FFAppBar(
        destinations: destinations,
        currentRoute: 'orders',
        onRouteSelected: (id) => route = id,
      );
      sut = buildSut();
      setViewport(tester, size);
      await tester.pumpWidget(sut);
      await tester.tap(find.text('Gestión'));
      await tester.pumpAndSettle();
      expect(find.text('Pedidos'), findsOneWidget);
      await tester.tap(find.text('Pedidos'));
      await tester.pumpAndSettle();
      expect(route, 'orders');
    },
  );

  testWidgets('usa el selectedIcon del enlace de la ruta actual', (
    tester,
  ) async {
    size = wideSize;
    appBar = FFAppBar(
      destinations: destinations,
      currentRoute: 'orders',
      onRouteSelected: (_) {},
    );
    sut = buildSut();
    setViewport(tester, size);
    await tester.pumpWidget(sut);
    await tester.tap(find.text('Gestión'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.receipt_long), findsOneWidget);
  });

  testWidgets('aplica colores de enlaces al elemento seleccionado del menú', (
    tester,
  ) async {
    final FFAppBar bar = FFAppBar(
      destinations: destinations,
      currentRoute: 'orders',
      onRouteSelected: _ignoreRoute,
      responsive: FFValue(
        xs: FFAppBarStyle(
          linkColor: FFColor.fixed(Colors.grey),
          selectedLinkColor: FFColor.fixed(Colors.white),
          selectedLinkBackgroundColor: FFColor.fixed(Colors.indigo),
        ),
      ),
    );
    size = wideSize;
    appBar = bar;
    sut = buildSut();
    setViewport(tester, size);
    await tester.pumpWidget(sut);
    await tester.tap(find.text('Gestión'));
    await tester.pumpAndSettle();

    final selected = tester.widget<MenuItemButton>(
      find
          .ancestor(
            of: find.text('Pedidos').last,
            matching: find.byType(MenuItemButton),
          )
          .first,
    );
    expect(selected.style, isNotNull);
    expect(selected.leadingIcon, isA<Icon>());
  });

  testWidgets('acciones y trailing se muestran en el orden configurado', (
    tester,
  ) async {
    appBar = const FFAppBar(
      actions: [FFAction(icon: Icon(Icons.add), label: 'Nuevo')],
      trailing: [Icon(Icons.account_circle)],
    );
    sut = buildSut();
    setViewport(tester, size);
    await tester.pumpWidget(sut);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byIcon(Icons.account_circle), findsOneWidget);
  });

  testWidgets('colores, bottom custom y toolbarHeight llegan al AppBar', (
    tester,
  ) async {
    const bar = FFAppBar(
      responsive: FFValue(
        xs: FFAppBarStyle(
          backgroundColor: FFColor.fixed(Colors.red),
          foregroundColor: FFColor.fixed(Colors.white),
          elevation: 3,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(12),
        child: SizedBox(height: 12),
      ),
      toolbarHeight: 58,
    );
    appBar = bar;
    sut = buildSut();
    setViewport(tester, size);
    await tester.pumpWidget(sut);

    final materialBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(materialBar.backgroundColor, Colors.red);
    expect(materialBar.foregroundColor, Colors.white);
    expect(materialBar.elevation, 3);
    expect(materialBar.toolbarHeight, 58);
    expect(materialBar.bottom, same(bar.bottom));
  });

  testWidgets('brand logo cabe en cuadrado y onTap es interactivo', (
    tester,
  ) async {
    var taps = 0;
    appBar = FFAppBar(
      brand: FFBrand(
        logo: const Icon(Icons.store),
        title: const Text('Tienda'),
        onTap: () => taps++,
      ),
    );
    sut = buildSut();
    setViewport(tester, size);
    await tester.pumpWidget(sut);
    await tester.tap(find.text('Tienda'));
    expect(taps, 1);
    expect(tester.getSize(find.byType(FittedBox).first), const Size(28, 28));
  });

  testWidgets('conserva el espacio superior de status bar al ocultarse', (
    tester,
  ) async {
    tester.view.physicalSize = phoneSize;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    sut = const Center(
      child: MediaQuery(
        data: MediaQueryData(padding: EdgeInsets.only(top: 24)),
        child: FFAppBar(responsive: FFValue(xs: FFAppBarStyle(visible: false))),
      ),
    );
    await tester.pumpWidget(sut);
    expect(
      tester
          .getSize(
            find.byWidgetPredicate(
              (widget) => widget is SizedBox && widget.height == 24,
            ),
          )
          .height,
      24,
    );
  });
}

void _ignoreRoute(String _) {}
