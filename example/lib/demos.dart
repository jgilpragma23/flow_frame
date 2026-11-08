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
        style: const FFStyle(padding: FFSpacing(all: FFValue(xs: 16, md: 32))),
        child: FFFlex(
          gap: const FFValue(xs: 16, md: 24),
          children: [
            FFItem(
              style: const FFStyle(
                textStyle: FFValue(
                  xs: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  md: TextStyle(fontSize: 30),
                ),
              ),
              child: Text('$title · ${context.breakpoint.name}'),
            ),
            FFItem(
              style: const FFStyle(color: AppColors.muted),
              child: Text(intro),
            ),
            ...children,
          ],
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
      child: FFContainer(
        style: FFStyle(
          margin: FFSpacing(all: margin, left: marginLeft),
          padding: vertical == null
              ? FFSpacing(all: padding)
              : FFSpacing(horizontal: padding, vertical: vertical),
          backgroundColor: FFValue(xs: _paddingColor),
        ),
        child: FFContainer(
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
          const FFItem(
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
          const FFItem(
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
                FFItem(style: _badge.merge(variant), child: Text(name)),
            ],
          ),
          natural: true,
        ),
        _section(
          context,
          'Size: width xs 100% · md 360 · lg 480, height xs 64 · md 96',
          const FFItem(
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
              FFItem(
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
        FFContainer(
          style: const FFStyle(
            padding: FFSpacing(all: FFValue(xs: 16, md: 24)),
            backgroundColor: FFValue(xs: AppColors.surface),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FFItem(
                style: FFStyle(
                  fontSize: FFValue.all(20),
                  fontWeight: FFValue.all(FontWeight.w700),
                  color: AppColors.primary,
                ),
                child: Text('A card using the palette'),
              ),
              const SizedBox(height: 6),
              const FFItem(
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
              child: FFContainer(
                maxSize: max,
                style: const FFStyle(
                  padding: FFSpacing(all: FFValue(xs: 12, md: 16)),
                  backgroundColor: FFValue(xs: AppColors.primarySoft),
                  color: AppColors.primary,
                  fontWeight: FFValue.all(FontWeight.w600),
                ),
                child: Text(
                  'maxSize: ${max.round()} · current width: '
                  '${constraints.maxWidth.clamp(0, max).round()} px',
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
