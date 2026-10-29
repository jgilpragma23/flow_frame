import 'package:flutter/material.dart';
import 'package:flow_frame/flow_frame.dart';

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
  static const background = FFColor.adaptive(
    light: Color(0xFFFFFFFF),
    dark: Color(0xFF0F0F0F),
  );
  static const surface = FFColor.adaptive(
    light: Color(0xFFF5F5F5),
    dark: Color(0xFF1E1E1E),
  );
  static const primary = FFColor.adaptive(
    light: Color(0xFF2563EB),
    dark: Color(0xFF60A5FA),
  );
  static const muted = FFColor.adaptive(
    light: Color(0xFF666666),
    dark: Color(0xFF9E9E9E),
  );
  static const primarySoft = FFColor.adaptive(
    light: Color(0xFFDBEAFE),
    dark: Color(0xFF1E3A5F),
  );
}

const card = FFStyle(
  padding: FFSpacing(all: FFValue(xs: 12, md: 20)),
  backgroundColor: AppColors.surface,
  height: FFValue.all(110),
);

const label = FFStyle(
  textStyle: FFValue(
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
    FFDestination(
      id: 'ejemplos',
      icon: Icon(Icons.grid_view_outlined),
      selectedIcon: Icon(Icons.grid_view),
      label: 'Ejemplos',
    ),
    FFDestination(
      id: 'ventas',
      icon: Icon(Icons.storefront_outlined),
      selectedIcon: Icon(Icons.storefront),
      label: 'Ventas',
      children: [
        FFDestination(
          id: 'ventas/pedidos',
          icon: Icon(Icons.receipt_long_outlined),
          label: 'Pedidos',
        ),
        FFDestination(
          id: 'ventas/clientes',
          icon: Icon(Icons.people_outline),
          label: 'Clientes',
        ),
        FFDestination(
          id: 'ventas/facturas',
          icon: Icon(Icons.request_quote_outlined),
          label: 'Facturas',
        ),
      ],
    ),
    FFDestination(
      id: 'reportes',
      icon: Icon(Icons.bar_chart_outlined),
      label: 'Reportes',
      visible: FFValue(xs: false, md: true),
    ),
    FFDestination(
      id: 'config',
      icon: Icon(Icons.settings_outlined),
      label: 'Configuración',
      alwaysOpen: true,
      children: [
        FFDestination(
          id: 'config/perfil',
          icon: Icon(Icons.person_outline),
          label: 'Perfil',
        ),
        FFDestination(
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
    return FFScaffold(
      appBar: AppBar(
        title: const Text('web_responsive'),
        actions: [
          FFActions(
            actions: [
              FFAction(
                icon: const Icon(Icons.add),
                label: 'Nuevo pedido',
                onPressed: () {},
                display: const FFValue(
                  xs: FFActionDisplay.icon,
                  md: FFActionDisplay.full,
                ),
              ),
              FFAction(
                icon: const Icon(Icons.download_outlined),
                label: 'Exportar',
                onPressed: () {},
                display: const FFValue(
                  xs: FFActionDisplay.menu,
                  lg: FFActionDisplay.full,
                ),
              ),
              FFAction(
                icon: const Icon(Icons.print_outlined),
                label: 'Imprimir',
                onPressed: () {},
                display: const FFValue(
                  xs: FFActionDisplay.hidden,
                  md: FFActionDisplay.menu,
                ),
              ),
              FFAction(
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
      responsive: FFValue(
        xs: FFNavStyle(
          type: drawer ? FFNavigation.drawer : FFNavigation.bottom,
          backgroundColor: AppColors.surface,
          iconColor: AppColors.muted,
          labelColor: AppColors.muted,
          selectedBackgroundColor: AppColors.primarySoft,
          selectedIconColor: AppColors.primary,
          selectedLabelColor: AppColors.primary,
        ),
        md: FFNavStyle(
          type: top ? FFNavigation.appBar : FFNavigation.rail,
          expandMode: WRRailExpand.overlay,
          shadow: true,
        ),
        lg: const FFNavStyle(expandMode: WRRailExpand.sidebar, expanded: true),
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
        (_) => FFScaffold.of(context).openMenu(),
      );
    }
    return SingleChildScrollView(
      child: FFContainer(
        maxSize: 1280,
        style: const FFStyle(
          padding: FFSpacing(
            horizontal: FFValue(xs: 16, md: 32),
            vertical: FFValue(xs: 16, md: 32),
          ),
        ),
        child: FFFlex(
          gap: const FFValue(xs: 16, md: 24),
          children: [
            FFItem(
              style: const FFStyle(
                textStyle: FFValue(
                  xs: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  md: TextStyle(fontSize: 34),
                ),
                textAlign: FFValue(xs: TextAlign.center, md: TextAlign.start),
              ),
              child: Text(
                'Breakpoint actual: ${context.breakpoint.name} '
                '(${MediaQuery.sizeOf(context).width.round()} px)',
              ),
            ),
            const FFItem(
              style: FFStyle(color: AppColors.muted),
              child: Text(
                'Grilla con col: FFValue(xs: 12, md: 6, lg: 4). '
                'Uno por fila en xs, dos en md y tres en lg; '
                'lo que no cabe baja a la siguiente fila.',
              ),
            ),
            FFFlex(
              direction: const FFValue.all(Axis.horizontal),
              gap: const FFValue(xs: 12, md: 16),
              children: [
                for (var i = 1; i <= 5; i++)
                  FFItem(
                    col: const FFValue(xs: 12, md: 6, lg: 4),
                    style: card.merge(const FFStyle(height: FFValue.all(80))),
                    child: _CardBody('Producto $i', 'col: xs 12, md 6, lg 4'),
                  ),
              ],
            ),
            const FFItem(
              style: FFStyle(color: AppColors.muted),
              child: Text(
                'Mezcla en una fila: col 3, fill y un ícono de tamaño natural. '
                'En xs el col 12 ocupa toda la fila y los otros bajan.',
              ),
            ),
            FFFlex(
              direction: const FFValue.all(Axis.horizontal),
              gap: const FFValue(xs: 12, md: 16),
              crossAxisAlignment: const FFValue.all(CrossAxisAlignment.center),
              children: [
                FFItem(
                  col: const FFValue(xs: 12, md: 3),
                  style: card.merge(const FFStyle(height: FFValue.all(80))),
                  child: const _CardBody('Filtros', 'col: xs 12, md 3'),
                ),
                FFItem(
                  fill: const FFValue.all(true),
                  style: card.merge(const FFStyle(height: FFValue.all(80))),
                  child: const _CardBody('Buscador', 'fill: true'),
                ),
                FFItem(
                  style: const FFStyle(color: AppColors.primary),
                  child: const Icon(Icons.tune, size: 32),
                ),
              ],
            ),
            const FFItem(
              style: FFStyle(color: AppColors.muted),
              child: Text(
                'FFFlex vertical en xs/sm y horizontal desde md. '
                'La tarjeta B tiene visible: FFValue(xs: false, md: true).',
              ),
            ),
            FFFlex(
              direction: const FFValue(xs: Axis.vertical, md: Axis.horizontal),
              gap: const FFValue(xs: 12, md: 16),
              children: [
                _card('A', 'fill: md true'),
                FFItem(
                  fill: const FFValue(md: true),
                  style: card.merge(
                    const FFStyle(
                      visible: FFValue(xs: false, md: true),
                      backgroundColor: FFColor.adaptive(
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
            const FFItem(
              style: FFStyle(color: AppColors.muted),
              child: Text(
                'Sidebar de 260 px y el contenido llena el resto, desde md',
              ),
            ),
            FFFlex(
              direction: const FFValue(xs: Axis.vertical, md: Axis.horizontal),
              gap: const FFValue(xs: 12, md: 16),
              children: [
                FFItem(
                  style: card.merge(const FFStyle(width: FFValue(md: 260))),
                  child: const _CardBody('Sidebar', 'width: md 260'),
                ),
                FFItem(
                  fill: const FFValue(md: true),
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

  FFItem _card(String title, String note) => FFItem(
    fill: const FFValue(md: true),
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
          style: const FFStyle(color: AppColors.muted).toTextStyle(context),
        ),
      ],
    );
  }
}

/// Página de pedidos: resumen en grilla, filtros con buscador y lista con
/// detalle.
class PedidosPage extends StatelessWidget {
  const PedidosPage({super.key});

  static const _card = FFStyle(
    padding: FFSpacing(all: FFValue(xs: 12, md: 20)),
    backgroundColor: AppColors.surface,
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: FFContainer(
        maxSize: 1280,
        style: const FFStyle(padding: FFSpacing(all: FFValue(xs: 16, md: 32))),
        child: FFFlex(
          gap: const FFValue(xs: 16, md: 24),
          children: [
            const FFItem(
              style: FFStyle(
                textStyle: FFValue(
                  xs: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  md: TextStyle(fontSize: 30),
                ),
              ),
              child: Text('Pedidos'),
            ),
            FFFlex(
              direction: const FFValue.all(Axis.horizontal),
              gap: const FFValue(xs: 12, md: 16),
              children: [
                for (final (title, value) in [
                  ('Hoy', '24'),
                  ('Semana', '183'),
                  ('Pendientes', '7'),
                  ('Ingresos', '\$4.2k'),
                ])
                  FFItem(
                    col: const FFValue(xs: 12, sm: 6, lg: 3),
                    style: _card,
                    child: _CardBody(value, title),
                  ),
              ],
            ),
            FFFlex(
              direction: const FFValue.all(Axis.horizontal),
              gap: const FFValue.all(12),
              crossAxisAlignment: const FFValue.all(CrossAxisAlignment.center),
              children: [
                const FFItem(
                  col: FFValue(xs: 12, md: 3),
                  style: _card,
                  child: _CardBody('Filtros', 'col: xs 12, md 3'),
                ),
                const FFItem(
                  fill: FFValue.all(true),
                  style: _card,
                  child: _CardBody('Buscar pedido…', 'fill: true'),
                ),
                FFItem(
                  child: FilledButton(
                    onPressed: () {},
                    child: const Text('Nuevo'),
                  ),
                ),
              ],
            ),
            FFFlex(
              direction: const FFValue(xs: Axis.vertical, md: Axis.horizontal),
              gap: const FFValue(xs: 12, md: 16),
              children: [
                FFItem(
                  col: const FFValue(md: 7, xl: 8),
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
                const FFItem(
                  fill: FFValue(md: true),
                  style: FFStyle(
                    padding: FFSpacing(all: FFValue(xs: 12, md: 20)),
                    backgroundColor: AppColors.primarySoft,
                    visible: FFValue(xs: false, md: true),
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
