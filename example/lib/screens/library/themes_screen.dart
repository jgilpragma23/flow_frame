import 'package:flutter/material.dart';
import 'package:flow_frame/flow_frame.dart';

import '../../widgets/demo_widgets.dart';
import '../../theme/color_utils.dart';

class ThemesScreen extends StatelessWidget {
  const ThemesScreen({super.key, required this.onToggleTheme});

  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const adaptive = FFColor.adaptive(
      light: Color(0xFF2563EB),
      dark: Color(0xFF93C5FD),
    );
    return DemoPage(
      title: 'Themes',
      intro:
          'FFColor reads Theme brightness; use Flutter ThemeMode to switch '
          'the app and every adaptive color together.',
      children: [
        DemoTopicSection(
          title: 'Current mode: ${isDark ? 'dark' : 'light'}',
          description:
              'Switch the app theme here or from the app-bar action. The '
              'colors on this page and the rest of the example update live.',
          child: FilledButton.icon(
            onPressed: onToggleTheme,
            icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode),
            label: Text(isDark ? 'Use light theme' : 'Use dark theme'),
          ),
        ),
        DemoTopicSection(
          title: 'One semantic color, two values',
          description:
              'The same FFColor resolves to a different Flutter Color '
              'according to the active Theme.',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                width: 84,
                height: 56,
                decoration: BoxDecoration(
                  color: adaptive.resolve(context),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              Text(
                'Resolved: ${colorToHex(adaptive.resolve(context))}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const DemoCodeSample('''MaterialApp(
  theme: ThemeData(brightness: Brightness.light),
  darkTheme: ThemeData(brightness: Brightness.dark),
  themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
)

const brand = FFColor.adaptive(
  light: Color(0xFF2563EB),
  dark: Color(0xFF93C5FD),
);'''),
      ],
    );
  }
}
