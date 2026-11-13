import 'package:flow_frame/flow_frame.dart';
import 'package:flutter/material.dart';

import 'main.dart';

/// Pages in the "Library" section, one per topic, demonstrating how each
/// feature adapts per breakpoint and providing images for the README.

/// Page title, explanatory text, and content.
class _DemoPage extends StatelessWidget {
  const _DemoPage({
    required this.title,
    required this.intro,
    required this.children,
  });

  final String title;
  final String intro;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: FFContainer(
        maxSize: 1280,
        child: FFStyled(
          style: const FFStyle(
            padding: FFSpacing(all: FFValue(xs: 16, md: 32)),
          ),
          child: FFFlex(
            gap: const FFValue(xs: 16, md: 24),
            children: [
              FFStyledItem(
                style: const FFStyle(
                  textStyle: FFValue(
                    xs: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                    md: TextStyle(fontSize: 30),
                  ),
                ),
                child: Text('$title · ${context.breakpoint.name}'),
              ),
              FFStyledItem(
                style: const FFStyle(color: AppColors.muted),
                child: Text(intro),
              ),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

/// Small, subdued text for labeling values.
class _Note extends StatelessWidget {
  const _Note(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const FFStyle(
      color: AppColors.muted,
      fontSize: FFValue.all(13),
    ).toTextStyle(context),
  );
}

String _px(FFValue<double> value, BuildContext context) =>
    '${(value.resolve(context.breakpoint) ?? 0).round()} px';

class _TopicSection extends StatelessWidget {
  const _TopicSection({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 4),
      _Note(description),
      const SizedBox(height: 10),
      child,
    ],
  );
}

class _CodeSample extends StatelessWidget {
  const _CodeSample(this.code);

  final String code;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
    ),
    child: SelectableText(
      code,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        fontFamily: 'monospace',
        height: 1.5,
      ),
    ),
  );
}

// ─── Breakpoints ─────────────────────────────────────────────────────────

class BreakpointsDemo extends StatelessWidget {
  const BreakpointsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return _DemoPage(
      title: 'Breakpoints',
      intro:
          'FFBreakpointScope sets responsive thresholds for a subtree. '
          'FFValue cascades from xs to the active breakpoint.',
      children: [
        _TopicSection(
          title: 'Active breakpoint',
          description:
              'Current viewport: ${width.round()} px · '
              'resolved as ${context.breakpoint.name}.',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final breakpoint in BreakpointEnum.values)
                Chip(
                  avatar: Icon(
                    breakpoint == context.breakpoint
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    size: 16,
                  ),
                  label: Text(breakpoint.name),
                ),
            ],
          ),
        ),
        _CodeSample('''FFBreakpointScope(
  breakpoints: const FFBreakpoints(
    sm: 640, md: 900, lg: 1200, xl: 1600,
  ),
  child: const MyApp(),
)

final columns = FFValue(xs: 12, md: 6, lg: 4);'''),
        _TopicSection(
          title: 'One value, responsive layout',
          description:
              'The cards change from one column to two and then three '
              'without duplicating the page.',
          child: FFFlex(
            direction: const FFValue.all(FFDirectionEnum.horizontal),
            gap: const FFValue.all(12),
            children: [
              for (var i = 1; i <= 3; i++)
                FFStyledItem(
                  col: const FFValue(xs: 12, md: 6, lg: 4),
                  style: const FFStyle(
                    padding: FFSpacing(all: FFValue.all(16)),
                    backgroundColor: FFValue(xs: AppColors.primarySoft),
                    color: AppColors.primary,
                  ),
                  child: Text('FFValue(xs: 12, md: 6, lg: 4) · $i'),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Grid ────────────────────────────────────────────────────────────────

class GridDemo extends StatelessWidget {
  const GridDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return _DemoPage(
      title: 'Grid',
      intro:
          'FFFlex arranges children. FFItem controls column width, fill, '
          'order, and visibility; it does not apply visual styles.',
      children: [
        _TopicSection(
          title: 'Grid without the styling API',
          description:
              'These cells use only FFFlex and FFItem. Their decoration is '
              'ordinary Flutter UI, independent of the grid.',
          child: FFFlex(
            direction: const FFValue.all(FFDirectionEnum.horizontal),
            gap: const FFValue.all(12),
            children: [
              for (final (col, title) in [
                (const FFValue(xs: 12, md: 6, lg: 4), 'One third'),
                (const FFValue(xs: 12, md: 6, lg: 4), 'One third'),
                (const FFValue(xs: 12, md: 6, lg: 4), 'One third'),
              ])
                FFItem(
                  col: col,
                  child: _GridTile(title, 'FFItem · col: xs 12, md 6, lg 4'),
                ),
            ],
          ),
        ),
        const _CodeSample('''FFFlex(
  direction: const FFValue.all(FFDirectionEnum.horizontal),
  gap: const FFValue.all(12),
  children: [
    FFItem(
      col: const FFValue(xs: 12, md: 6, lg: 4),
      child: const MyCard(),
    ),
  ],
)'''),
        _TopicSection(
          title: 'Opt in to styling when you need it',
          description:
              'FFStyledItem composes grid sizing with independent text, '
              'decoration, and layout styles.',
          child: FFFlex(
            direction: const FFValue.all(FFDirectionEnum.horizontal),
            gap: const FFValue.all(12),
            children: [
              FFStyledItem.compose(
                col: const FFValue(xs: 12, md: 6),
                text: const FFTextStyle(
                  color: AppColors.primary,
                  fontWeight: FFValue.all(FontWeight.w700),
                ),
                decoration: const FFDecorationStyle(
                  backgroundColor: FFValue(xs: AppColors.primarySoft),
                ),
                layout: const FFLayoutStyle(
                  padding: FFSpacing(all: FFValue.all(16)),
                ),
                child: const Text('Grid + decoration + typography'),
              ),
              const FFItem(
                fill: FFValue.all(true),
                child: _GridTile('Flexible', 'FFItem(fill: true)'),
              ),
            ],
          ),
        ),
        const _CodeSample('''FFStyledItem.compose(
  col: const FFValue(xs: 12, md: 6),
  text: const FFTextStyle(color: AppColors.primary),
  decoration: const FFDecorationStyle(
    backgroundColor: FFValue(xs: AppColors.primarySoft),
  ),
  child: const Text('Styled column'),
)'''),
      ],
    );
  }
}

class _GridTile extends StatelessWidget {
  const _GridTile(this.title, this.subtitle);

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    ),
  );
}

// ─── Typography ──────────────────────────────────────────────────────────

class TypographyDemo extends StatelessWidget {
  const TypographyDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return _DemoPage(
      title: 'Typography',
      intro:
          'FFTextStyle owns text properties only. Apply it directly with '
          'FFStyled, or combine it with other style responsibilities.',
      children: [
        _TopicSection(
          title: 'Responsive heading',
          description:
              'Font size, weight, alignment, and color can be selected '
              'independently at each breakpoint.',
          child: FFStyled(
            text: const FFTextStyle(
              color: AppColors.primary,
              fontSize: FFValue(xs: 22, md: 30, lg: 38),
              fontWeight: FFValue.all(FontWeight.w800),
              textAlign: FFValue(xs: TextAlign.center, md: TextAlign.start),
            ),
            child: const Text('Readable at every size'),
          ),
        ),
        const _CodeSample('''FFStyled(
  text: const FFTextStyle(
    color: AppColors.primary,
    fontSize: FFValue(xs: 22, md: 30, lg: 38),
    fontWeight: FFValue.all(FontWeight.w800),
    textAlign: FFValue(xs: TextAlign.center, md: TextAlign.start),
  ),
  child: const Text('Readable at every size'),
)'''),
        _TopicSection(
          title: 'Line height for body copy',
          description:
              'Use lineHeight as a multiplier; longer text gets more '
              'breathing room at larger breakpoints.',
          child: FFStyled(
            text: const FFTextStyle(
              fontSize: FFValue(xs: 14, lg: 18),
              lineHeight: FFValue(xs: 1.35, lg: 1.7),
            ),
            child: const Text(
              'Flow Frame resolves responsive text values using the same '
              'breakpoint scope as the grid. This paragraph adapts its size '
              'and line spacing while the rest of the interface can remain '
              'completely independent.',
            ),
          ),
        ),
        _TopicSection(
          title: 'Combine responsibilities only when useful',
          description:
              'FFStyle remains a convenience composition; each part can '
              'also be applied on its own.',
          child: FFStyled(
            text: const FFTextStyle(
              color: AppColors.primary,
              fontWeight: FFValue.all(FontWeight.w700),
            ),
            decoration: const FFDecorationStyle(
              backgroundColor: FFValue(xs: AppColors.primarySoft),
            ),
            layout: const FFLayoutStyle(
              padding: FFSpacing(all: FFValue.all(12)),
            ),
            child: const Text('Text + decoration + layout'),
          ),
        ),
      ],
    );
  }
}

// ─── Themes ──────────────────────────────────────────────────────────────

class ThemeDemo extends StatelessWidget {
  const ThemeDemo({super.key, required this.onToggleTheme});

  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const adaptive = FFColor.adaptive(
      light: Color(0xFF2563EB),
      dark: Color(0xFF93C5FD),
    );
    return _DemoPage(
      title: 'Themes',
      intro:
          'FFColor reads Theme brightness; use Flutter ThemeMode to switch '
          'the app and every adaptive color together.',
      children: [
        _TopicSection(
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
        _TopicSection(
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
                'Resolved: ${ColorsDemo._hex(adaptive.resolve(context))}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const _CodeSample('''MaterialApp(
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

// ─── Navigation ──────────────────────────────────────────────────────────

class NavigationDemo extends StatelessWidget {
  const NavigationDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return _DemoPage(
      title: 'Navigation',
      intro:
          'FFScaffold adapts navigation to available width. This example '
          'uses its bottom bar on phones, rail on tablets, and sidebar on '
          'desktop; try resizing the window.',
      children: [
        _TopicSection(
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
        const _CodeSample('''FFScaffold(
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
        _TopicSection(
          title: 'Customize destinations per breakpoint',
          description:
              'Visibility and navigation styles are responsive values too. '
              'The app-bar demo shows how FFAppBar can also be used alone.',
          child: const _CodeSample(
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

// ─── Spacing ─────────────────────────────────────────────────────────────

const _marginColor = FFColor.adaptive(
  light: Color(0xFFFDE7C8),
  dark: Color(0xFF4A3312),
);
const _paddingColor = FFColor.adaptive(
  light: Color(0xFFCDEFD9),
  dark: Color(0xFF173B26),
);

class SpacingDemo extends StatelessWidget {
  const SpacingDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return _DemoPage(
      title: 'Spacing',
      intro:
          'FFSpacing with a value per breakpoint. Orange = margin, '
          'green = padding, blue = content.',
      children: [
        _legend(context),
        _box(
          context,
          'padding all: xs 8 · md 24 · lg 40\nmargin all: xs 0 · md 16 · lg 32',
          padding: const FFValue(xs: 8, md: 24, lg: 40),
          margin: const FFValue(xs: 0, md: 16, lg: 32),
        ),
        _box(
          context,
          'padding horizontal: xs 12 · md 48 · lg 96, vertical: 8',
          padding: const FFValue(xs: 12, md: 48, lg: 96),
          vertical: const FFValue.all(8),
        ),
        _box(
          context,
          'margin left: xs 0 · md 64 · lg 160 (indentation)',
          padding: const FFValue.all(12),
          marginLeft: const FFValue(xs: 0, md: 64, lg: 160),
        ),
      ],
    );
  }

  Widget _legend(BuildContext context) => Wrap(
    spacing: 16,
    runSpacing: 8,
    children: [
      for (final (name, color) in [
        ('margin', _marginColor),
        ('padding', _paddingColor),
        ('content', AppColors.primarySoft),
      ])
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 14, height: 14, color: color.resolve(context)),
            const SizedBox(width: 6),
            _Note(name),
          ],
        ),
    ],
  );

  Widget _box(
    BuildContext context,
    String code, {
    required FFValue<double> padding,
    FFValue<double>? vertical,
    FFValue<double>? margin,
    FFValue<double>? marginLeft,
  }) {
    final now = [
      'padding ${_px(padding, context)}',
      if (margin != null) 'margin ${_px(margin, context)}',
      if (marginLeft != null) 'margin left ${_px(marginLeft, context)}',
    ].join(' · ');
    return ColoredBox(
      color: _marginColor.resolve(context),
      child: FFStyled(
        style: FFStyle(
          margin: FFSpacing(all: margin, left: marginLeft),
          padding: vertical == null
              ? FFSpacing(all: padding)
              : FFSpacing(horizontal: padding, vertical: vertical),
          backgroundColor: FFValue(xs: _paddingColor),
        ),
        child: FFContainer(
          child: FFStyled(
            style: const FFStyle(
              padding: FFSpacing(all: FFValue.all(12)),
              backgroundColor: FFValue(xs: AppColors.primarySoft),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  code,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                ),
                const SizedBox(height: 6),
                _Note('now: $now'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Styles ─────────────────────────────────────────────────────────────

const _badge = FFStyle(
  padding: FFSpacing(
    horizontal: FFValue(xs: 10, md: 16),
    vertical: FFValue(xs: 6, md: 10),
  ),
  fontWeight: FFValue.all(FontWeight.w600),
  fontSize: FFValue(xs: 13, md: 15),
  backgroundColor: FFValue(xs: AppColors.surface),
);

const _variants = [
  ('base', FFStyle()),
  (
    'primary',
    FFStyle(
      backgroundColor: FFValue(xs: AppColors.primarySoft),
      color: AppColors.primary,
    ),
  ),
  (
    'success',
    FFStyle(
      backgroundColor: FFValue(
        xs: FFColor.adaptive(light: Color(0xFFDCFCE7), dark: Color(0xFF14361F)),
      ),
      color: FFColor.adaptive(
        light: Color(0xFF15803D),
        dark: Color(0xFF4ADE80),
      ),
    ),
  ),
  (
    'danger',
    FFStyle(
      backgroundColor: FFValue(
        xs: FFColor.adaptive(light: Color(0xFFFEE2E2), dark: Color(0xFF451A1A)),
      ),
      color: FFColor.adaptive(
        light: Color(0xFFB91C1C),
        dark: Color(0xFFF87171),
      ),
    ),
  ),
];

class StylesDemo extends StatelessWidget {
  const StylesDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return _DemoPage(
      title: 'Styles',
      intro:
          'FFStyle combines text, color, background, size, and spacing. Each '
          'value can change per breakpoint, and styles can be combined with merge.',
      children: [
        _section(
          context,
          'Text: fontSize xs 20 · md 28 · lg 40, centered on xs',
          const FFStyledItem(
            style: FFStyle(
              fontSize: FFValue(xs: 20, md: 28, lg: 40),
              fontWeight: FFValue(xs: FontWeight.w600, lg: FontWeight.w900),
              textAlign: FFValue(xs: TextAlign.center, md: TextAlign.start),
              color: AppColors.primary,
            ),
            child: Text('Sales this month'),
          ),
        ),
        _section(
          context,
          'Paragraph: fontSize xs 14 · lg 18, lineHeight xs 1.3 · lg 1.7',
          const FFStyledItem(
            style: FFStyle(
              fontSize: FFValue(xs: 14, lg: 18),
              lineHeight: FFValue(xs: 1.3, lg: 1.7),
            ),
            child: Text(
              'Text grows and has more breathing room on larger screens; on '
              'phones it is more compact to fit without scrolling. '
              'All of this comes from the same FFStyle.',
            ),
          ),
        ),
        _section(
          context,
          'Variants with _badge.merge(variant): padding and size change per '
          'breakpoint, while each variant provides its color',
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final (name, variant) in _variants)
                FFStyledItem(style: _badge.merge(variant), child: Text(name)),
            ],
          ),
          natural: true,
        ),
        _section(
          context,
          'Size: width xs 100% · md 360 · lg 480, height xs 64 · md 96',
          const FFStyledItem(
            style: FFStyle(
              width: FFValue(xs: double.infinity, md: 360, lg: 480),
              height: FFValue(xs: 64, md: 96),
              backgroundColor: FFValue(xs: AppColors.primarySoft),
              padding: FFSpacing(all: FFValue.all(12)),
              color: AppColors.primary,
            ),
            child: Text('Card'),
          ),
          natural: true,
        ),
      ],
    );
  }

  /// With [natural], the child keeps its natural width and aligns left;
  /// otherwise it uses the full width to demonstrate `textAlign`.
  Widget _section(
    BuildContext context,
    String note,
    Widget child, {
    bool natural = false,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _Note(note),
      const SizedBox(height: 8),
      natural ? Align(alignment: Alignment.centerLeft, child: child) : child,
    ],
  );
}

// ─── Colors ─────────────────────────────────────────────────────────────

class ColorsDemo extends StatelessWidget {
  const ColorsDemo({super.key});

  static const _palette = [
    ('background', AppColors.background),
    ('surface', AppColors.surface),
    ('primary', AppColors.primary),
    ('primarySoft', AppColors.primarySoft),
    ('muted', AppColors.muted),
  ];

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return _DemoPage(
      title: 'Colors',
      intro:
          'FFColor.adaptive(light: ..., dark: ...) selects a color based on '
          'the Theme. Current mode: ${dark ? 'dark' : 'light'}.',
      children: [
        FFFlex(
          direction: const FFValue.all(FFDirectionEnum.horizontal),
          gap: const FFValue.all(12),
          children: [
            for (final (name, color) in _palette)
              FFStyledItem(
                col: const FFValue(xs: 6, md: 4, lg: 2),
                style: const FFStyle(
                  backgroundColor: FFValue(xs: AppColors.surface),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 72,
                      decoration: BoxDecoration(
                        color: color.resolve(context),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          _Note(_hex(color.resolve(context))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        FFStyled(
          style: const FFStyle(
            padding: FFSpacing(all: FFValue(xs: 16, md: 24)),
            backgroundColor: FFValue(xs: AppColors.surface),
          ),
          child: FFContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FFStyledItem(
                  style: FFStyle(
                    fontSize: FFValue.all(20),
                    fontWeight: FFValue.all(FontWeight.w700),
                    color: AppColors.primary,
                  ),
                  child: Text('A card using the palette'),
                ),
                const SizedBox(height: 6),
                const FFStyledItem(
                  style: FFStyle(color: AppColors.muted),
                  child: Text(
                    'Surface background, primary title, and muted text.',
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(onPressed: () {}, child: const Text('Action')),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static String _hex(Color c) =>
      '#${c.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
}

// ─── Container ──────────────────────────────────────────────────────────

class ContainerDemo extends StatelessWidget {
  const ContainerDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return _DemoPage(
      title: 'Container',
      intro:
          'FFContainer uses the available width up to maxSize and centers '
          'itself. The gray background is the free space on the sides.',
      children: [
        for (final max in [480.0, 800.0, 1100.0])
          LayoutBuilder(
            builder: (context, constraints) => ColoredBox(
              color: AppColors.surface.resolve(context),
              child: FFStyled(
                style: const FFStyle(
                  padding: FFSpacing(all: FFValue(xs: 12, md: 16)),
                  backgroundColor: FFValue(xs: AppColors.primarySoft),
                  color: AppColors.primary,
                  fontWeight: FFValue.all(FontWeight.w600),
                ),
                child: FFContainer(
                  maxSize: max,
                  child: Text(
                    'maxSize: ${max.round()} · current width: '
                    '${constraints.maxWidth.clamp(0, max).round()} px',
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── App bar ────────────────────────────────────────────────────────────

class AppBarDemo extends StatelessWidget {
  const AppBarDemo({super.key});

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
    return _DemoPage(
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
      _Note(note),
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
