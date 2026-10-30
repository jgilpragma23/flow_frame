import 'package:flow_frame/flow_frame.dart';
import 'package:flutter/material.dart';

import 'main.dart';

/// Páginas de la sección "Librería": una por tema, para ver cómo cambia
/// cada cosa según el breakpoint (y para las imágenes del README).

/// Título, texto de ayuda y el contenido de la página.
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

/// Un texto chico y apagado, para anotar los valores.
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

// ─── Espaciado ──────────────────────────────────────────────────────────

const _marginColor = FFColor.adaptive(
  light: Color(0xFFFDE7C8),
  dark: Color(0xFF4A3312),
);
const _paddingColor = FFColor.adaptive(
  light: Color(0xFFCDEFD9),
  dark: Color(0xFF173B26),
);

class EspaciadoDemo extends StatelessWidget {
  const EspaciadoDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return _DemoPage(
      title: 'Espaciado',
      intro:
          'FFSpacing con un valor por breakpoint. Naranja = margin, '
          'verde = padding, azul = contenido.',
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
          'margin left: xs 0 · md 64 · lg 160 (sangría)',
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
        ('contenido', AppColors.primarySoft),
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
              _Note('ahora: $now'),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Estilos ────────────────────────────────────────────────────────────

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
    'primario',
    FFStyle(
      backgroundColor: FFValue(xs: AppColors.primarySoft),
      color: AppColors.primary,
    ),
  ),
  (
    'éxito',
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
    'peligro',
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

class EstilosDemo extends StatelessWidget {
  const EstilosDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return _DemoPage(
      title: 'Estilos',
      intro:
          'FFStyle junta texto, color, fondo, tamaño y espaciado. Cada valor '
          'puede cambiar por breakpoint y los estilos se combinan con merge.',
      children: [
        _section(
          context,
          'Texto: fontSize xs 20 · md 28 · lg 40, centrado en xs',
          const FFItem(
            style: FFStyle(
              fontSize: FFValue(xs: 20, md: 28, lg: 40),
              fontWeight: FFValue(xs: FontWeight.w600, lg: FontWeight.w900),
              textAlign: FFValue(xs: TextAlign.center, md: TextAlign.start),
              color: AppColors.primary,
            ),
            child: Text('Ventas del mes'),
          ),
        ),
        _section(
          context,
          'Párrafo: fontSize xs 14 · lg 18, lineHeight xs 1.3 · lg 1.7',
          const FFItem(
            style: FFStyle(
              fontSize: FFValue(xs: 14, lg: 18),
              lineHeight: FFValue(xs: 1.3, lg: 1.7),
            ),
            child: Text(
              'En pantallas grandes el texto crece y respira más; en el '
              'teléfono es más compacto para que quepa sin hacer scroll. '
              'Todo sale del mismo FFStyle.',
            ),
          ),
        ),
        _section(
          context,
          'Variantes con _badge.merge(variante): padding y tamaño cambian '
          'por breakpoint, el color lo pone cada variante',
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
          'Tamaño: width xs 100% · md 360 · lg 480, height xs 64 · md 96',
          const FFItem(
            style: FFStyle(
              width: FFValue(xs: double.infinity, md: 360, lg: 480),
              height: FFValue(xs: 64, md: 96),
              backgroundColor: FFValue(xs: AppColors.primarySoft),
              padding: FFSpacing(all: FFValue.all(12)),
              color: AppColors.primary,
            ),
            child: Text('Tarjeta'),
          ),
          natural: true,
        ),
      ],
    );
  }

  /// Con [natural] el hijo queda con su propio ancho, a la izquierda; si no,
  /// usa todo el ancho (para que se note el textAlign).
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

// ─── Colores ────────────────────────────────────────────────────────────

class ColoresDemo extends StatelessWidget {
  const ColoresDemo({super.key});

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
      title: 'Colores',
      intro:
          'FFColor.adaptive(light: ..., dark: ...) elige solo según el '
          'Theme. Ahora: modo ${dark ? 'oscuro' : 'claro'}.',
      children: [
        FFFlex(
          direction: const FFValue.all(FFDirection.horizontal),
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
                child: Text('Una tarjeta con la paleta'),
              ),
              const SizedBox(height: 6),
              const FFItem(
                style: FFStyle(color: AppColors.muted),
                child: Text('Fondo surface, título primary y texto muted.'),
              ),
              const SizedBox(height: 12),
              FilledButton(onPressed: () {}, child: const Text('Acción')),
            ],
          ),
        ),
      ],
    );
  }

  static String _hex(Color c) =>
      '#${c.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
}

// ─── Contenedor ─────────────────────────────────────────────────────────

class ContenedorDemo extends StatelessWidget {
  const ContenedorDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return _DemoPage(
      title: 'Contenedor',
      intro:
          'FFContainer ocupa todo el ancho hasta maxSize y se centra. El '
          'fondo gris es el espacio libre a los lados.',
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
                  'maxSize: ${max.round()} · ancho ahora: '
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
    title: Text('Mi Tienda'),
  );

  /// Los enlaces aparecen desde md.
  static const _links = [
    FFDestination(
      id: 'inicio',
      icon: Icon(Icons.home_outlined),
      label: 'Inicio',
      visible: FFValue(xs: false, md: true),
    ),
    FFDestination(
      id: 'productos',
      icon: Icon(Icons.category_outlined),
      label: 'Productos',
      visible: FFValue(xs: false, md: true),
      children: [
        FFDestination(
          id: 'productos/nuevos',
          icon: Icon(Icons.fiber_new_outlined),
          label: 'Nuevos',
        ),
        FFDestination(
          id: 'productos/ofertas',
          icon: Icon(Icons.local_offer_outlined),
          label: 'Ofertas',
        ),
      ],
    ),
    FFDestination(
      id: 'contacto',
      icon: Icon(Icons.mail_outline),
      label: 'Contacto',
      visible: FFValue(xs: false, lg: true),
    ),
  ];

  static final _actions = [
    FFAction(icon: const Icon(Icons.search), label: 'Buscar', onPressed: () {}),
    FFAction(
      icon: const Icon(Icons.shopping_cart),
      label: 'Carrito',
      onPressed: () {},
      display: const FFValue(
        xs: FFActionDisplay.icon,
        lg: FFActionDisplay.full,
      ),
    ),
    FFAction(
      icon: const Icon(Icons.help_outline),
      label: 'Ayuda',
      onPressed: () {},
      display: const FFValue(
        xs: FFActionDisplay.menu,
        md: FFActionDisplay.icon,
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _DemoPage(
      title: 'App bar',
      intro:
          'FFAppBar va en el appBar de cualquier Scaffold, sin FFScaffold. '
          'Cada caja de abajo es un Scaffold normal.',
      children: [
        _frame(
          context,
          'Marca, enlaces y acciones: en xs solo la marca al centro; los '
          'enlaces aparecen desde md y "Contacto" desde lg.',
          FFAppBar(
            brand: _brand,
            destinations: _links,
            currentRoute: 'inicio',
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
          'Título de la página: en xs reemplaza a la marca; desde md van '
          'los dos.',
          FFAppBar(
            brand: _brand,
            title: const Text('Pedidos'),
            actions: _actions,
            responsive: const FFValue(
              xs: FFAppBarStyle(showBrand: false),
              md: FFAppBarStyle(showBrand: true),
            ),
          ),
        ),
        _frame(
          context,
          'visible: oculto en xs (el contenido sube) y de color desde md.',
          const FFAppBar(
            title: Text('Solo en tablet y escritorio'),
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
              child: Text('Contenido de la página'),
            ),
          ),
        ),
      ),
    ],
  );
}
