enum ExampleRoute {
  examples,
  salesOrders,
  salesCustomers,
  salesInvoices,
  libraryBreakpoints,
  libraryGrid,
  libraryStyles,
  libraryTypography,
  librarySpacing,
  libraryColors,
  libraryThemes,
  libraryContainer,
  libraryNavigation,
  libraryAppBar,
  reports,
  settingsProfile,
  settingsSecurity,
}

extension ExampleRouteDetails on ExampleRoute {
  String get id => switch (this) {
    ExampleRoute.examples => 'examples',
    ExampleRoute.salesOrders => 'sales/orders',
    ExampleRoute.salesCustomers => 'sales/customers',
    ExampleRoute.salesInvoices => 'sales/invoices',
    ExampleRoute.libraryBreakpoints => 'library/breakpoints',
    ExampleRoute.libraryGrid => 'library/grid',
    ExampleRoute.libraryStyles => 'library/styles',
    ExampleRoute.libraryTypography => 'library/typography',
    ExampleRoute.librarySpacing => 'library/spacing',
    ExampleRoute.libraryColors => 'library/colors',
    ExampleRoute.libraryThemes => 'library/themes',
    ExampleRoute.libraryContainer => 'library/container',
    ExampleRoute.libraryNavigation => 'library/navigation',
    ExampleRoute.libraryAppBar => 'library/app-bar',
    ExampleRoute.reports => 'reports',
    ExampleRoute.settingsProfile => 'settings/profile',
    ExampleRoute.settingsSecurity => 'settings/security',
  };

  String get title => switch (this) {
    ExampleRoute.examples => 'Examples',
    ExampleRoute.salesOrders => 'Orders',
    ExampleRoute.salesCustomers => 'Customers',
    ExampleRoute.salesInvoices => 'Invoices',
    ExampleRoute.libraryBreakpoints => 'Breakpoints',
    ExampleRoute.libraryGrid => 'Grid',
    ExampleRoute.libraryStyles => 'Styles',
    ExampleRoute.libraryTypography => 'Typography',
    ExampleRoute.librarySpacing => 'Spacing',
    ExampleRoute.libraryColors => 'Colors',
    ExampleRoute.libraryThemes => 'Themes',
    ExampleRoute.libraryContainer => 'Container',
    ExampleRoute.libraryNavigation => 'Navigation',
    ExampleRoute.libraryAppBar => 'App bar',
    ExampleRoute.reports => 'Reports',
    ExampleRoute.settingsProfile => 'Profile',
    ExampleRoute.settingsSecurity => 'Security',
  };

  static ExampleRoute? fromId(String id) {
    for (final route in ExampleRoute.values) {
      if (route.id == id) return route;
    }
    return null;
  }
}
