import 'package:flutter/material.dart';

import '../../widgets/demo_widgets.dart';

class NavigationScreen extends StatelessWidget {
  const NavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoPage(
      title: 'Navigation',
      intro:
          'FFScaffold adapts navigation to available width. This example '
          'uses its bottom bar on phones, rail on tablets, and sidebar on '
          'desktop; try resizing the window.',
      children: [
        DemoTopicSection(
          title: 'The current screen is the live demo',
          description:
              'Select pages from the Library section. On narrow screens '
              'the destinations move to the bottom bar; nested destinations '
              'become a drawer, rail, or expanded sidebar as space allows.',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final (icon, label) in [
                (Icons.smartphone, 'Phone · bottom navigation'),
                (Icons.tablet, 'Tablet · navigation rail'),
                (Icons.desktop_windows, 'Desktop · sidebar'),
              ])
                Chip(avatar: Icon(icon, size: 18), label: Text(label)),
            ],
          ),
        ),
        const DemoCodeSample('''FFScaffold(
  currentRoute: selectedRoute,
  onRouteSelected: (id) => setState(() => selectedRoute = id),
  destinations: const [
    FFDestination(id: 'home', icon: Icon(Icons.home), label: 'Home'),
    FFDestination(
      id: 'library',
      icon: Icon(Icons.auto_awesome),
      label: 'Library',
      children: [
        FFDestination(
          id: 'library/colors',
          icon: Icon(Icons.palette_outlined),
          label: 'Colors',
        ),
      ],
    ),
  ],
  responsive: const FFValue(
    xs: FFNavStyle(type: FFNavigationEnum.bottom),
    md: FFNavStyle(type: FFNavigationEnum.rail),
    lg: FFNavStyle(expandMode: FFRailExpandEnum.sidebar),
  ),
)'''),
        DemoTopicSection(
          title: 'Customize destinations per breakpoint',
          description:
              'Visibility and navigation styles are responsive values too. '
              'The app-bar demo shows how FFAppBar can also be used alone.',
          child: const DemoCodeSample(
            "FFDestination(\n"
            "  id: 'reports',\n"
            "  icon: Icon(Icons.bar_chart),\n"
            "  label: 'Reports',\n"
            "  visible: FFValue(xs: false, md: true),\n"
            ')',
          ),
        ),
      ],
    );
  }
}
