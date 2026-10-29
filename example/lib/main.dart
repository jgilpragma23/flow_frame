import 'package:flutter/material.dart';
import 'package:web_responsive/web_responsive.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Uri.base.queryParameters['dark'] == '1';
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(brightness: Brightness.light),
      darkTheme: ThemeData(brightness: Brightness.dark),
      home: const ExampleShell(),
    );
  }
}

/// Colores de esta página, con su versión clara y oscura.
class AppColors {
  static const background = WRColor.adaptive(
    light: Color(0xFFFFFFFF),
    dark: Color(0xFF0F0F0F),
  );
  static const surface = WRColor.adaptive(
    light: Color(0xFFF5F5F5),
    dark: Color(0xFF1E1E1E),
  );
  static const primary = WRColor.adaptive(
    light: Color(0xFF2563EB),
    dark: Color(0xFF60A5FA),
  );
  static const muted = WRColor.adaptive(
    light: Color(0xFF666666),
    dark: Color(0xFF9E9E9E),
  );
  static const primarySoft = WRColor.adaptive(
    light: Color(0xFFDBEAFE),
    dark: Color(0xFF1E3A5F),
  );
}

const card = WRStyle(
  padding: WRSpacing(all: WRValue(xs: 12, md: 20)),
  backgroundColor: AppColors.surface,
  height: WRValue.all(110),
);

const label = WRStyle(
  textStyle: WRValue(
    xs: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    md: TextStyle(fontSize: 22),
  ),
  color: AppColors.primary,
);

/// La app con su navegación: barra abajo en teléfono, rail en tablet (el
/// menú se abre encima) y menú abierto en escritorio (empuja el contenido).
///
/// Para los screenshots: ?nav=drawer usa drawer en teléfono, ?nav=top
/// usa enlaces en el app bar desde md, `?sel=id`
/// elige la ruta inicial y ?open=1 abre el menú al iniciar.
class ExampleShell extends StatefulWidget {
  const ExampleShell({super.key});

  @override
  State<ExampleShell> createState() => _ExampleShellState();
}

class _ExampleShellState extends State<ExampleShell> {
  String _selected = Uri.base.queryParameters['sel'] ?? 'ejemplos';

  static const _destinations = [
    WRDestination(
      id: 'ejemplos',
      icon: Icon(Icons.grid_view_outlined),
      selectedIcon: Icon(Icons.grid_view),
      label: 'Ejemplos',
    ),
    WRDestination(
      id: 'ventas',
      icon: Icon(Icons.storefront_outlined),
      selectedIcon: Icon(Icons.storefront),
      label: 'Ventas',
      children: [
        WRDestination(
          id: 'ventas/pedidos',
          icon: Icon(Icons.receipt_long_outlined),
          label: 'Pedidos',
        ),
        WRDestination(
          id: 'ventas/clientes',
          icon: Icon(Icons.people_outline),
          label: 'Clientes',
        ),
        WRDestination(
          id: 'ventas/facturas',
          icon: Icon(Icons.request_quote_outlined),
          label: 'Facturas',
        ),
      ],
    ),
    WRDestination(
      id: 'reportes',
      icon: Icon(Icons.bar_chart_outlined),
      label: 'Reportes',
      visible: WRValue(xs: false, md: true),
    ),
    WRDestination(
      id: 'config',
      icon: Icon(Icons.settings_outlined),
      label: 'Configuración',
      alwaysOpen: true,
      children: [
        WRDestination(
          id: 'config/perfil',
          icon: Icon(Icons.person_outline),
          label: 'Perfil',
        ),
        WRDestination(
          id: 'config/seguridad',
          icon: Icon(Icons.lock_outline),
          label: 'Seguridad',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final nav = Uri.base.queryParameters['nav'];
    final drawer = nav == 'drawer';
    final top = nav == 'top';
    return WRScaffold(
      appBar: AppBar(
        title: const Text('web_responsive'),
        actions: [
          WRActions(
            actions: [
              WRAction(
                icon: const Icon(Icons.add),
                label: 'Nuevo pedido',
                onPressed: () {},
                display: const WRValue(
                  xs: WRActionDisplay.icon,
                  md: WRActionDisplay.full,
                ),
              ),
              WRAction(
                icon: const Icon(Icons.download_outlined),
                label: 'Exportar',
                onPressed: () {},
                display: const WRValue(
                  xs: WRActionDisplay.menu,
                  lg: WRActionDisplay.full,
                ),
              ),
              WRAction(
                icon: const Icon(Icons.print_outlined),
                label: 'Imprimir',
                onPressed: () {},
                display: const WRValue(
                  xs: WRActionDisplay.hidden,
                  md: WRActionDisplay.menu,
                ),
              ),
              WRAction(
                icon: const Icon(Icons.notifications_outlined),
                label: 'Notificaciones',
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      backgroundColor: AppColors.background.resolve(context),
      currentRoute: _selected,
      onRouteSelected: (id) => setState(() => _selected = id),
      destinations: _destinations,
      responsive: WRValue(
        xs: WRNavStyle(
          type: drawer ? WRNavigation.drawer : WRNavigation.bottom,
          backgroundColor: AppColors.surface,
          iconColor: AppColors.muted,
          labelColor: AppColors.muted,
          selectedBackgroundColor: AppColors.primarySoft,
          selectedIconColor: AppColors.primary,
          selectedLabelColor: AppColors.primary,
        ),
        md: WRNavStyle(
          type: top ? WRNavigation.appBar : WRNavigation.rail,
          expandMode: WRRailExpand.overlay,
          shadow: true,
        ),
        lg: const WRNavStyle(expandMode: WRRailExpand.sidebar, expanded: true),
      ),
      body: switch (_selected) {
        'ejemplos' => const ExamplePage(),
        'ventas/pedidos' => const PedidosPage(),
        _ => _Placeholder(_selected),
      },
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder(this.title);

  final String title;

  @override
  Widget build(BuildContext context) =>
      Center(child: Text(title, style: label.toTextStyle(context)));
}

class ExamplePage extends StatelessWidget {
  const ExamplePage({super.key});

  /// Con ?open=1 abre el menú al iniciar (para los screenshots).
  static bool _openedMenu = false;

  @override
  Widget build(BuildContext context) {
    if (!_openedMenu && Uri.base.queryParameters['open'] == '1') {
      _openedMenu = true;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => WRScaffold.of(context).openMenu(),
      );
    }
    return SingleChildScrollView(
      child: WRContainer(
        maxSize: 1280,
        style: const WRStyle(
          padding: WRSpacing(
            horizontal: WRValue(xs: 16, md: 32),
            vertical: WRValue(xs: 16, md: 32),
          ),
        ),
        child: WRFlex(
          gap: const WRValue(xs: 16, md: 24),
          children: [
            WRItem(
              style: const WRStyle(
                textStyle: WRValue(
                  xs: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  md: TextStyle(fontSize: 34),
                ),
                textAlign: WRValue(xs: TextAlign.center, md: TextAlign.start),
              ),
              child: Text(
                'Breakpoint actual: ${context.breakpoint.name} '
                '(${MediaQuery.sizeOf(context).width.round()} px)',
              ),
            ),
            const WRItem(
              style: WRStyle(color: AppColors.muted),
              child: Text(
                'Grilla con col: WRValue(xs: 12, md: 6, lg: 4). '
                'Uno por fila en xs, dos en md y tres en lg; '
                'lo que no cabe baja a la siguiente fila.',
              ),
            ),
            WRFlex(
              direction: const WRValue.all(Axis.horizontal),
              gap: const WRValue(xs: 12, md: 16),
              children: [
                for (var i = 1; i <= 5; i++)
                  WRItem(
                    col: const WRValue(xs: 12, md: 6, lg: 4),
                    style: card.merge(const WRStyle(height: WRValue.all(80))),
                    child: _CardBody('Producto $i', 'col: xs 12, md 6, lg 4'),
                  ),
              ],
            ),
            const WRItem(
              style: WRStyle(color: AppColors.muted),
              child: Text(
                'Mezcla en una fila: col 3, fill y un ícono de tamaño natural. '
                'En xs el col 12 ocupa toda la fila y los otros bajan.',
              ),
            ),
            WRFlex(
              direction: const WRValue.all(Axis.horizontal),
              gap: const WRValue(xs: 12, md: 16),
              crossAxisAlignment: const WRValue.all(CrossAxisAlignment.center),
              children: [
                WRItem(
                  col: const WRValue(xs: 12, md: 3),
                  style: card.merge(const WRStyle(height: WRValue.all(80))),
                  child: const _CardBody('Filtros', 'col: xs 12, md 3'),
                ),
                WRItem(
                  fill: const WRValue.all(true),
                  style: card.merge(const WRStyle(height: WRValue.all(80))),
                  child: const _CardBody('Buscador', 'fill: true'),
                ),
                WRItem(
                  style: const WRStyle(color: AppColors.primary),
                  child: const Icon(Icons.tune, size: 32),
                ),
              ],
            ),
            const WRItem(
              style: WRStyle(color: AppColors.muted),
              child: Text(
                'WRFlex vertical en xs/sm y horizontal desde md. '
                'La tarjeta B tiene visible: WRValue(xs: false, md: true).',
              ),
            ),
            WRFlex(
              direction: const WRValue(xs: Axis.vertical, md: Axis.horizontal),
              gap: const WRValue(xs: 12, md: 16),
              children: [
                _card('A', 'fill: md true'),
                WRItem(
                  fill: const WRValue(md: true),
                  style: card.merge(
                    const WRStyle(
                      visible: WRValue(xs: false, md: true),
                      backgroundColor: WRColor.adaptive(
                        light: Color(0xFFFFF4D6),
                        dark: Color(0xFF3A2E14),
                      ),
                    ),
                  ),
                  child: const _CardBody('B', 'oculta en xs/sm'),
                ),
                _card('C', 'fill: md true'),
              ],
            ),
            const WRItem(
              style: WRStyle(color: AppColors.muted),
              child: Text(
                'Sidebar de 260 px y el contenido llena el resto, desde md',
              ),
            ),
            WRFlex(
              direction: const WRValue(xs: Axis.vertical, md: Axis.horizontal),
              gap: const WRValue(xs: 12, md: 16),
              children: [
                WRItem(
                  style: card.merge(const WRStyle(width: WRValue(md: 260))),
                  child: const _CardBody('Sidebar', 'width: md 260'),
                ),
                WRItem(
                  fill: const WRValue(md: true),
                  style: card,
                  child: const _CardBody('Contenido', 'fill: md true'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  WRItem _card(String title, String note) => WRItem(
    fill: const WRValue(md: true),
    style: card,
    child: _CardBody(title, note),
  );
}

class _CardBody extends StatelessWidget {
  const _CardBody(this.title, this.note);

  final String title;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: label.toTextStyle(context)),
        const SizedBox(height: 4),
        Text(
          note,
          style: const WRStyle(color: AppColors.muted).toTextStyle(context),
        ),
      ],
    );
  }
}

/// Página de pedidos: resumen en grilla, filtros con buscador y lista con
/// detalle.
class PedidosPage extends StatelessWidget {
  const PedidosPage({super.key});

  static const _card = WRStyle(
    padding: WRSpacing(all: WRValue(xs: 12, md: 20)),
    backgroundColor: AppColors.surface,
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: WRContainer(
        maxSize: 1280,
        style: const WRStyle(padding: WRSpacing(all: WRValue(xs: 16, md: 32))),
        child: WRFlex(
          gap: const WRValue(xs: 16, md: 24),
          children: [
            const WRItem(
              style: WRStyle(
                textStyle: WRValue(
                  xs: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  md: TextStyle(fontSize: 30),
                ),
              ),
              child: Text('Pedidos'),
            ),
            WRFlex(
              direction: const WRValue.all(Axis.horizontal),
              gap: const WRValue(xs: 12, md: 16),
              children: [
                for (final (title, value) in [
                  ('Hoy', '24'),
                  ('Semana', '183'),
                  ('Pendientes', '7'),
                  ('Ingresos', '\$4.2k'),
                ])
                  WRItem(
                    col: const WRValue(xs: 12, sm: 6, lg: 3),
                    style: _card,
                    child: _CardBody(value, title),
                  ),
              ],
            ),
            WRFlex(
              direction: const WRValue.all(Axis.horizontal),
              gap: const WRValue.all(12),
              crossAxisAlignment: const WRValue.all(CrossAxisAlignment.center),
              children: [
                const WRItem(
                  col: WRValue(xs: 12, md: 3),
                  style: _card,
                  child: _CardBody('Filtros', 'col: xs 12, md 3'),
                ),
                const WRItem(
                  fill: WRValue.all(true),
                  style: _card,
                  child: _CardBody('Buscar pedido…', 'fill: true'),
                ),
                WRItem(
                  child: FilledButton(
                    onPressed: () {},
                    child: const Text('Nuevo'),
                  ),
                ),
              ],
            ),
            WRFlex(
              direction: const WRValue(xs: Axis.vertical, md: Axis.horizontal),
              gap: const WRValue(xs: 12, md: 16),
              children: [
                WRItem(
                  col: const WRValue(md: 7, xl: 8),
                  style: _card,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _CardBody('Lista de pedidos', 'col: md 7, xl 8'),
                      for (var i = 1; i <= 4; i++)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.receipt_long_outlined),
                          title: Text('Pedido #10$i'),
                          trailing: Text('\$${i * 35}.00'),
                        ),
                    ],
                  ),
                ),
                const WRItem(
                  fill: WRValue(md: true),
                  style: WRStyle(
                    padding: WRSpacing(all: WRValue(xs: 12, md: 20)),
                    backgroundColor: AppColors.primarySoft,
                    visible: WRValue(xs: false, md: true),
                  ),
                  child: _CardBody(
                    'Detalle del pedido',
                    'fill: md true · oculto en xs/sm',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
