import 'package:flutter/material.dart';
import 'package:flow_frame/flow_frame.dart';

import '../../theme/app_colors.dart';
import '../../widgets/demo_widgets.dart';

class AppBarScreen extends StatelessWidget {
  const AppBarScreen({super.key});

  static const _brand = FFBrand(
    logo: Icon(Icons.storefront, color: Color(0xFF2563EB)),
    title: Text('My Store'),
  );

  /// Links are shown from md onward.
  static const _links = [
    FFDestination(
      id: 'home',
      icon: Icon(Icons.home_outlined),
      label: 'Home',
      visible: FFValue(xs: false, md: true),
    ),
    FFDestination(
      id: 'products',
      icon: Icon(Icons.category_outlined),
      label: 'Products',
      visible: FFValue(xs: false, md: true),
      children: [
        FFDestination(
          id: 'products/new',
          icon: Icon(Icons.fiber_new_outlined),
          label: 'New',
        ),
        FFDestination(
          id: 'products/offers',
          icon: Icon(Icons.local_offer_outlined),
          label: 'Offers',
        ),
      ],
    ),
    FFDestination(
      id: 'contact',
      icon: Icon(Icons.mail_outline),
      label: 'Contact',
      visible: FFValue(xs: false, lg: true),
    ),
  ];

  static final _actions = [
    FFAction(icon: const Icon(Icons.search), label: 'Search', onPressed: () {}),
    FFAction(
      icon: const Icon(Icons.shopping_cart),
      label: 'Cart',
      onPressed: () {},
      display: const FFValue(
        xs: FFActionDisplayEnum.icon,
        lg: FFActionDisplayEnum.full,
      ),
    ),
    FFAction(
      icon: const Icon(Icons.help_outline),
      label: 'Help',
      onPressed: () {},
      display: const FFValue(
        xs: FFActionDisplayEnum.menu,
        md: FFActionDisplayEnum.icon,
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DemoPage(
      title: 'App bar',
      intro:
          'FFAppBar can be used in the appBar of any Scaffold, without '
          'FFScaffold. Each example below is a regular Scaffold.',
      children: [
        _frame(
          context,
          'Branding, links, and actions: on xs only centered branding is '
          'shown; links appear from md onward and "Contact" from lg.',
          FFAppBar(
            brand: _brand,
            destinations: _links,
            currentRoute: 'home',
            onRouteSelected: (_) {},
            actions: _actions,
            responsive: const FFValue(
              xs: FFAppBarStyle(
                centerTitle: true,
                backgroundColor: AppColors.surface,
              ),
            ),
          ),
        ),
        _frame(
          context,
          'Page title: on xs it replaces the branding; from md onward both '
          'are shown.',
          FFAppBar(
            brand: _brand,
            title: const Text('Orders'),
            actions: _actions,
            responsive: const FFValue(
              xs: FFAppBarStyle(showBrand: false),
              md: FFAppBarStyle(showBrand: true),
            ),
          ),
        ),
        _frame(
          context,
          'visible: hidden on xs (content moves up) and colored from md onward.',
          const FFAppBar(
            title: Text('Tablet and desktop only'),
            responsive: FFValue(
              xs: FFAppBarStyle(visible: false),
              md: FFAppBarStyle(
                visible: true,
                backgroundColor: AppColors.primary,
                foregroundColor: FFColor.fixed(Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _frame(BuildContext context, String note, FFAppBar bar) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      DemoNote(note),
      const SizedBox(height: 8),
      ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 150,
          child: Scaffold(
            appBar: bar,
            backgroundColor: AppColors.primarySoft.resolve(context),
            body: const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Page content'),
            ),
          ),
        ),
      ),
    ],
  );
}
