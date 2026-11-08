import 'package:flutter/material.dart';
import 'package:flow_frame/flow_frame.dart';

import 'demos.dart';

void main() {
  FFBreakpoints.current = const FFBreakpoints(
    sm: 640,
    md: 900,
    lg: 1200,
    xl: 1600,
  );
  runApp(const ExampleApp());
}

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

/// Colors used on this page, with light- and dark-mode variants.
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
  backgroundColor: FFValue(xs: AppColors.surface),
  height: FFValue.all(110),
);

const label = FFStyle(
  textStyle: FFValue(
    xs: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    md: TextStyle(fontSize: 22),
  ),
  color: AppColors.primary,
);

/// App navigation: bottom bar on phones, rail on tablets (the menu overlays
/// the content), and an open menu on desktops (which pushes the content).
///
/// For screenshots: `?nav=drawer` uses a drawer on phones, `?nav=top` uses
/// app bar links from md onward, `?sel=id` selects the initial route, and
/// `?open=1` opens the menu on startup.
class ExampleShell extends StatefulWidget {
  const ExampleShell({super.key});

  @override
  State<ExampleShell> createState() => _ExampleShellState();
}

class _ExampleShellState extends State<ExampleShell> {
  String _selected = Uri.base.queryParameters['sel'] ?? 'examples';

  static const _destinations = [
    FFDestination(
      id: 'examples',
      icon: Icon(Icons.grid_view_outlined),
      selectedIcon: Icon(Icons.grid_view),
      label: 'Examples',
    ),
    FFDestination(
      id: 'library',
      icon: Icon(Icons.auto_awesome_outlined),
      selectedIcon: Icon(Icons.auto_awesome),
      label: 'Library',
      children: [
        FFDestination(
          id: 'library/styles',
          icon: Icon(Icons.text_fields),
          label: 'Styles',
        ),
        FFDestination(
          id: 'library/spacing',
          icon: Icon(Icons.padding_outlined),
          label: 'Spacing',
        ),
        FFDestination(
          id: 'library/colors',
          icon: Icon(Icons.palette_outlined),
          label: 'Colors',
        ),
        FFDestination(
          id: 'library/container',
          icon: Icon(Icons.crop_free),
          label: 'Container',
        ),
        FFDestination(
          id: 'library/app-bar',
          icon: Icon(Icons.web_asset),
          label: 'App bar',
        ),
      ],
    ),
    FFDestination(
      id: 'sales',
      icon: Icon(Icons.storefront_outlined),
      selectedIcon: Icon(Icons.storefront),
      label: 'Sales',
      children: [
        FFDestination(
          id: 'sales/orders',
          icon: Icon(Icons.receipt_long_outlined),
          label: 'Orders',
        ),
        FFDestination(
          id: 'sales/customers',
          icon: Icon(Icons.people_outline),
          label: 'Customers',
        ),
        FFDestination(
          id: 'sales/invoices',
          icon: Icon(Icons.request_quote_outlined),
          label: 'Invoices',
        ),
      ],
    ),
    FFDestination(
      id: 'reports',
      icon: Icon(Icons.bar_chart_outlined),
      label: 'Reports',
      visible: FFValue(xs: false, md: true),
    ),
    FFDestination(
      id: 'settings',
      icon: Icon(Icons.settings_outlined),
      label: 'Settings',
      alwaysOpen: true,
      children: [
        FFDestination(
          id: 'settings/profile',
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
        FFDestination(
          id: 'settings/security',
          icon: Icon(Icons.lock_outline),
          label: 'Security',
        ),
      ],
    ),
  ];

  /// Current route name, including subroutes.
  String get _title {
    for (final d in _destinations) {
      if (d.id == _selected) return d.label;
      for (final c in d.children) {
        if (c.id == _selected) return c.label;
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final nav = Uri.base.queryParameters['nav'];
    final drawer = nav == 'drawer';
    final top = nav == 'top';
    return FFScaffold(
      brand: FFBrand(
        logo: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.primary.resolve(context),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.storefront_outlined,
            color: Colors.white,
            size: 18,
          ),
        ),
        title: const Text('My Store'),
        subtitle: const Text('Admin'),
        onTap: () => setState(() => _selected = 'examples'),
      ),
      appBar: FFAppBar(
        title: Text(_title),
        actions: [
          FFAction(
            icon: const Icon(Icons.add),
            label: 'New order',
            onPressed: () {},
            display: const FFValue(
              xs: FFActionDisplayEnum.icon,
              md: FFActionDisplayEnum.full,
            ),
          ),
          FFAction(
            icon: const Icon(Icons.download_outlined),
            label: 'Export',
            onPressed: () {},
            display: const FFValue(
              xs: FFActionDisplayEnum.menu,
              lg: FFActionDisplayEnum.full,
            ),
          ),
          FFAction(
            icon: const Icon(Icons.print_outlined),
            label: 'Print',
            onPressed: () {},
            display: const FFValue(
              xs: FFActionDisplayEnum.hidden,
              md: FFActionDisplayEnum.menu,
            ),
          ),
          FFAction(
            icon: const Icon(Icons.notifications_outlined),
            label: 'Notifications',
            onPressed: () {},
          ),
        ],
        trailing: const [SizedBox(width: 8)],
      ),
      backgroundColor: AppColors.background.resolve(context),
      currentRoute: _selected,
      onRouteSelected: (id) => setState(() => _selected = id),
      destinations: _destinations,
      responsive: FFValue(
        xs: FFNavStyle(
          type: drawer ? FFNavigationEnum.drawer : FFNavigationEnum.bottom,
          backgroundColor: AppColors.surface,
          iconColor: AppColors.muted,
          labelColor: AppColors.muted,
          selectedBackgroundColor: AppColors.primarySoft,
          selectedIconColor: AppColors.primary,
          selectedLabelColor: AppColors.primary,
        ),
        md: FFNavStyle(
          type: drawer
              ? FFNavigationEnum.drawer
              : top
              ? FFNavigationEnum.appBar
              : FFNavigationEnum.rail,
          expandMode: FFRailExpandEnum.overlay,
          shadow: true,
        ),
        lg: const FFNavStyle(
          expandMode: FFRailExpandEnum.sidebar,
          expanded: true,
        ),
      ),
      body: switch (_selected) {
        'examples' => const ExamplePage(),
        'sales/orders' => const OrdersPage(),
        'library/styles' => const StylesDemo(),
        'library/spacing' => const SpacingDemo(),
        'library/colors' => const ColorsDemo(),
        'library/container' => const ContainerDemo(),
        'library/app-bar' => const AppBarDemo(),
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

  /// Opens the menu on startup with `?open=1` (for screenshots).
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
                'Current breakpoint: ${context.breakpoint.name} '
                '(${MediaQuery.sizeOf(context).width.round()} px)',
              ),
            ),
            const FFItem(
              style: FFStyle(color: AppColors.muted),
              child: Text(
                'Grid with col: FFValue(xs: 12, md: 6, lg: 4). '
                'One per row on xs, two on md, and three on lg; '
                'items that do not fit wrap to the next row.',
              ),
            ),
            FFFlex(
              direction: const FFValue.all(FFDirectionEnum.horizontal),
              gap: const FFValue(xs: 12, md: 16),
              children: [
                for (var i = 1; i <= 5; i++)
                  FFItem(
                    col: const FFValue(xs: 12, md: 6, lg: 4),
                    style: card.merge(const FFStyle(height: FFValue.all(80))),
                    child: _CardBody('Product $i', 'col: xs 12, md 6, lg 4'),
                  ),
              ],
            ),
            const FFItem(
              style: FFStyle(color: AppColors.muted),
              child: Text(
                'Mixed in one row: col 3, fill, and a naturally sized icon. '
                'On xs, col 12 uses the full row and the others wrap below.',
              ),
            ),
            FFFlex(
              direction: const FFValue.all(FFDirectionEnum.horizontal),
              gap: const FFValue(xs: 12, md: 16),
              crossAxisAlignment: const FFValue.all(CrossAxisAlignment.center),
              children: [
                FFItem(
                  col: const FFValue(xs: 12, md: 3),
                  style: card.merge(const FFStyle(height: FFValue.all(80))),
                  child: const _CardBody('Filters', 'col: xs 12, md 3'),
                ),
                FFItem(
                  fill: const FFValue.all(true),
                  style: card.merge(const FFStyle(height: FFValue.all(80))),
                  child: const _CardBody('Search', 'fill: true'),
                ),
                FFItem(
                  fill: const FFValue.all(false),
                  style: const FFStyle(color: AppColors.primary),
                  child: const Icon(Icons.tune, size: 32),
                ),
              ],
            ),
            const FFItem(
              style: FFStyle(color: AppColors.muted),
              child: Text(
                'FFFlex is vertical on xs/sm and horizontal from md onward. '
                'Card B uses visible: FFValue(xs: false, md: true).',
              ),
            ),
            FFFlex(
              direction: const FFValue(
                xs: FFDirectionEnum.vertical,
                md: FFDirectionEnum.horizontal,
              ),
              gap: const FFValue(xs: 12, md: 16),
              children: [
                _card('A', 'fill: md true'),
                FFItem(
                  fill: const FFValue(md: true),
                  style: card.merge(
                    const FFStyle(
                      visible: FFValue(xs: false, md: true),
                      backgroundColor: FFValue(
                        xs: FFColor.adaptive(
                          light: Color(0xFFFFF4D6),
                          dark: Color(0xFF3A2E14),
                        ),
                      ),
                    ),
                  ),
                  child: const _CardBody('B', 'hidden on xs/sm'),
                ),
                _card('C', 'fill: md true'),
              ],
            ),
            const FFItem(
              style: FFStyle(color: AppColors.muted),
              child: Text(
                'A 260 px sidebar with the content filling the rest, from md onward',
              ),
            ),
            FFFlex(
              direction: const FFValue(
                xs: FFDirectionEnum.vertical,
                md: FFDirectionEnum.horizontal,
              ),
              gap: const FFValue(xs: 12, md: 16),
              children: [
                FFItem(
                  fill: const FFValue.all(false),
                  style: card.merge(const FFStyle(width: FFValue(md: 260))),
                  child: const _CardBody('Sidebar', 'width: md 260'),
                ),
                FFItem(
                  fill: const FFValue(md: true),
                  style: card,
                  child: const _CardBody('Content', 'fill: md true'),
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

/// Orders page: grid summary, filters with search, and a list with details.
class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  static const _card = FFStyle(
    padding: FFSpacing(all: FFValue(xs: 12, md: 20)),
    backgroundColor: FFValue(xs: AppColors.surface),
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
              child: Text('Orders'),
            ),
            FFFlex(
              direction: const FFValue.all(FFDirectionEnum.horizontal),
              gap: const FFValue(xs: 12, md: 16),
              children: [
                for (final (title, value) in [
                  ('Today', '24'),
                  ('This week', '183'),
                  ('Pending', '7'),
                  ('Revenue', '\$4.2k'),
                ])
                  FFItem(
                    col: const FFValue(xs: 12, sm: 6, lg: 3),
                    style: _card,
                    child: _CardBody(value, title),
                  ),
              ],
            ),
            FFFlex(
              direction: const FFValue.all(FFDirectionEnum.horizontal),
              gap: const FFValue.all(12),
              crossAxisAlignment: const FFValue.all(CrossAxisAlignment.center),
              children: [
                const FFItem(
                  col: FFValue(xs: 12, md: 3),
                  style: _card,
                  child: _CardBody('Filters', 'col: xs 12, md 3'),
                ),
                const FFItem(
                  fill: FFValue.all(true),
                  style: _card,
                  child: _CardBody('Search orders…', 'fill: true'),
                ),
                FFItem(
                  fill: const FFValue.all(false),
                  child: FilledButton(
                    onPressed: () {},
                    child: const Text('New'),
                  ),
                ),
              ],
            ),
            FFFlex(
              direction: const FFValue(
                xs: FFDirectionEnum.vertical,
                md: FFDirectionEnum.horizontal,
              ),
              gap: const FFValue(xs: 12, md: 16),
              children: [
                FFItem(
                  col: const FFValue(md: 7, xl: 8),
                  style: _card,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _CardBody('Order list', 'col: md 7, xl 8'),
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
                    backgroundColor: FFValue(xs: AppColors.primarySoft),
                    visible: FFValue(xs: false, md: true),
                  ),
                  child: _CardBody(
                    'Order details',
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
