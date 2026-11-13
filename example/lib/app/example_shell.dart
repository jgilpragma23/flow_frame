import 'package:flutter/material.dart';
import 'package:flow_frame/flow_frame.dart';

import '../models/example_route.dart';
import '../screens/example_screen.dart';
import '../screens/library/app_bar_screen.dart';
import '../screens/library/breakpoints_screen.dart';
import '../screens/library/colors_screen.dart';
import '../screens/library/container_screen.dart';
import '../screens/library/grid_screen.dart';
import '../screens/library/navigation_screen.dart';
import '../screens/library/spacing_screen.dart';
import '../screens/library/styles_screen.dart';
import '../screens/library/themes_screen.dart';
import '../screens/library/typography_screen.dart';
import '../screens/orders_screen.dart';
import '../theme/app_colors.dart';
import '../theme/example_styles.dart';

class ExampleShell extends StatefulWidget {
  const ExampleShell({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  @override
  State<ExampleShell> createState() => _ExampleShellState();
}

class _ExampleShellState extends State<ExampleShell> {
  String _selected =
      Uri.base.queryParameters['sel'] ?? ExampleRoute.examples.id;

  static final _destinations = [
    FFDestination(
      id: ExampleRoute.examples.id,
      icon: const Icon(Icons.grid_view_outlined),
      selectedIcon: const Icon(Icons.grid_view),
      label: ExampleRoute.examples.title,
    ),
    FFDestination(
      id: 'library',
      icon: const Icon(Icons.auto_awesome_outlined),
      selectedIcon: const Icon(Icons.auto_awesome),
      label: 'Library',
      children: [
        FFDestination(
          id: ExampleRoute.libraryBreakpoints.id,
          icon: const Icon(Icons.devices_outlined),
          label: ExampleRoute.libraryBreakpoints.title,
        ),
        FFDestination(
          id: ExampleRoute.libraryGrid.id,
          icon: const Icon(Icons.grid_on_outlined),
          label: ExampleRoute.libraryGrid.title,
        ),
        FFDestination(
          id: ExampleRoute.libraryStyles.id,
          icon: const Icon(Icons.text_fields),
          label: ExampleRoute.libraryStyles.title,
        ),
        FFDestination(
          id: ExampleRoute.libraryTypography.id,
          icon: const Icon(Icons.format_size),
          label: ExampleRoute.libraryTypography.title,
        ),
        FFDestination(
          id: ExampleRoute.librarySpacing.id,
          icon: const Icon(Icons.padding_outlined),
          label: ExampleRoute.librarySpacing.title,
        ),
        FFDestination(
          id: ExampleRoute.libraryColors.id,
          icon: const Icon(Icons.palette_outlined),
          label: ExampleRoute.libraryColors.title,
        ),
        FFDestination(
          id: ExampleRoute.libraryThemes.id,
          icon: const Icon(Icons.dark_mode_outlined),
          label: ExampleRoute.libraryThemes.title,
        ),
        FFDestination(
          id: ExampleRoute.libraryContainer.id,
          icon: const Icon(Icons.crop_free),
          label: ExampleRoute.libraryContainer.title,
        ),
        FFDestination(
          id: ExampleRoute.libraryNavigation.id,
          icon: const Icon(Icons.navigation_outlined),
          label: ExampleRoute.libraryNavigation.title,
        ),
        FFDestination(
          id: ExampleRoute.libraryAppBar.id,
          icon: const Icon(Icons.web_asset),
          label: ExampleRoute.libraryAppBar.title,
        ),
      ],
    ),
    FFDestination(
      id: 'sales',
      icon: const Icon(Icons.storefront_outlined),
      selectedIcon: const Icon(Icons.storefront),
      label: 'Sales',
      children: [
        FFDestination(
          id: ExampleRoute.salesOrders.id,
          icon: const Icon(Icons.receipt_long_outlined),
          label: ExampleRoute.salesOrders.title,
        ),
        FFDestination(
          id: ExampleRoute.salesCustomers.id,
          icon: const Icon(Icons.people_outline),
          label: ExampleRoute.salesCustomers.title,
        ),
        FFDestination(
          id: ExampleRoute.salesInvoices.id,
          icon: const Icon(Icons.request_quote_outlined),
          label: ExampleRoute.salesInvoices.title,
        ),
      ],
    ),
    FFDestination(
      id: ExampleRoute.reports.id,
      icon: const Icon(Icons.bar_chart_outlined),
      label: ExampleRoute.reports.title,
      visible: const FFValue(xs: false, md: true),
    ),
    FFDestination(
      id: 'settings',
      icon: const Icon(Icons.settings_outlined),
      label: 'Settings',
      alwaysOpen: true,
      children: [
        FFDestination(
          id: ExampleRoute.settingsProfile.id,
          icon: const Icon(Icons.person_outline),
          label: ExampleRoute.settingsProfile.title,
        ),
        FFDestination(
          id: ExampleRoute.settingsSecurity.id,
          icon: const Icon(Icons.lock_outline),
          label: ExampleRoute.settingsSecurity.title,
        ),
      ],
    ),
  ];

  String get _title => ExampleRouteDetails.fromId(_selected)?.title ?? '';

  Widget get _screen => switch (ExampleRouteDetails.fromId(_selected)) {
    ExampleRoute.examples => const ExampleScreen(),
    ExampleRoute.salesOrders => const OrdersScreen(),
    ExampleRoute.libraryBreakpoints => const BreakpointsScreen(),
    ExampleRoute.libraryGrid => const GridScreen(),
    ExampleRoute.libraryStyles => const StylesScreen(),
    ExampleRoute.libraryTypography => const TypographyScreen(),
    ExampleRoute.librarySpacing => const SpacingScreen(),
    ExampleRoute.libraryColors => const ColorsScreen(),
    ExampleRoute.libraryThemes => ThemesScreen(
      onToggleTheme: widget.onToggleTheme,
    ),
    ExampleRoute.libraryContainer => const ContainerScreen(),
    ExampleRoute.libraryNavigation => const NavigationScreen(),
    ExampleRoute.libraryAppBar => const AppBarScreen(),
    _ => _Placeholder(_title.isEmpty ? _selected : _title),
  };

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
        onTap: () => setState(() => _selected = ExampleRoute.examples.id),
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
          FFAction(
            icon: Icon(
              widget.isDarkMode
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            label: widget.isDarkMode ? 'Light theme' : 'Dark theme',
            onPressed: widget.onToggleTheme,
            display: const FFValue(
              xs: FFActionDisplayEnum.icon,
              md: FFActionDisplayEnum.full,
            ),
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
      body: _screen,
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder(this.title);

  final String title;

  @override
  Widget build(BuildContext context) =>
      Center(child: Text(title, style: exampleLabelStyle.toTextStyle(context)));
}
