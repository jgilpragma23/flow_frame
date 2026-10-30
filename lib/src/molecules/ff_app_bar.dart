import 'package:flutter/material.dart';

import '../models/breakpoint.dart';
import '../models/ff_action.dart';
import '../models/ff_app_bar_style.dart';
import '../models/ff_brand.dart';
import '../models/ff_navigation.dart';
import '../models/ff_value.dart';
import '../utils/context_extensions.dart';
import 'ff_actions.dart';

const _duration = Duration(milliseconds: 220);

/// Un `AppBar` responsive que se usa solo, en el `appBar` de cualquier
/// `Scaffold`, sin el layout de `FFScaffold`.
///
/// Junta la marca, el título, enlaces de navegación (con grupos en
/// dropdown) y acciones que se acomodan por breakpoint. Con [responsive]
/// se oculta completo, se quita la marca o el título y se cambian los
/// colores en cada breakpoint.
///
/// Dentro de un `FFScaffold` recibe de él lo que no defina: la marca (si
/// no tiene [title]), los destinos y la ruta para los enlaces con
/// `FFNavigation.appBar`, y los colores del `FFNavStyle`.
class FFAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FFAppBar({
    super.key,
    this.brand,
    this.title,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.actions = const [],
    this.trailing = const [],
    this.destinations = const [],
    this.currentRoute,
    this.onRouteSelected,
    this.responsive,
    this.bottom,
    this.toolbarHeight,
  });

  /// Logo y nombre de la app, al inicio.
  final FFBrand? brand;

  /// Después de la marca, por ejemplo el nombre de la página.
  final Widget? title;
  final Widget? leading;
  final bool automaticallyImplyLeading;

  /// Acciones que cambian de forma por breakpoint, como en `FFActions`.
  final List<FFAction> actions;

  /// Widgets después de [actions], por ejemplo un avatar.
  final List<Widget> trailing;

  /// Enlaces después del título. Se muestran solo si hay
  /// [onRouteSelected]; respetan `FFDestination.visible`.
  final List<FFDestination> destinations;

  /// `id` de la ruta actual, para marcar su enlace.
  final String? currentRoute;
  final ValueChanged<String>? onRouteSelected;

  /// Visibilidad, marca, título y colores por breakpoint, en cascada.
  final FFValue<FFAppBarStyle>? responsive;
  final PreferredSizeWidget? bottom;
  final double? toolbarHeight;

  @override
  Size get preferredSize => Size.fromHeight(
    (toolbarHeight ?? kToolbarHeight) + (bottom?.preferredSize.height ?? 0),
  );

  /// Una copia con los valores dados reemplazados.
  FFAppBar copyWith({
    FFBrand? brand,
    Widget? title,
    List<FFDestination>? destinations,
    String? currentRoute,
    ValueChanged<String>? onRouteSelected,
    FFValue<FFAppBarStyle>? responsive,
  }) => FFAppBar(
    key: key,
    brand: brand ?? this.brand,
    title: title ?? this.title,
    leading: leading,
    automaticallyImplyLeading: automaticallyImplyLeading,
    actions: actions,
    trailing: trailing,
    destinations: destinations ?? this.destinations,
    currentRoute: currentRoute ?? this.currentRoute,
    onRouteSelected: onRouteSelected ?? this.onRouteSelected,
    responsive: responsive ?? this.responsive,
    bottom: bottom,
    toolbarHeight: toolbarHeight,
  );

  @override
  Widget build(BuildContext context) {
    final breakpoint = context.breakpoint;
    final style =
        responsive?.resolveMerged(breakpoint) ?? const FFAppBarStyle();
    // Oculto deja solo el espacio de la barra de estado, que el Scaffold
    // ya no agrega al cuerpo.
    if (style.visible == false) {
      return SizedBox(height: MediaQuery.paddingOf(context).top);
    }

    final brand = style.showBrand == false ? null : this.brand;
    final title = style.showTitle == false ? null : this.title;
    final links = onRouteSelected == null
        ? const <FFDestination>[]
        : visibleDestinations(destinations, breakpoint);

    Widget? heading;
    if (brand != null && title != null) {
      heading = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FFBrandBar(brand: brand),
          const SizedBox(width: 16),
          Flexible(child: title),
        ],
      );
    } else if (brand != null) {
      heading = FFBrandBar(brand: brand);
    } else {
      heading = title;
    }

    final linkColor = style.linkColor?.resolve(context);
    final selectedLinkColor = style.selectedLinkColor?.resolve(context);
    return AppBar(
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      title: links.isEmpty
          ? heading
          : Row(
              children: [
                if (heading != null) ...[heading, const SizedBox(width: 24)],
                Expanded(
                  child: FFNavLinks(
                    items: links,
                    currentRoute: currentRoute,
                    onSelected: onRouteSelected!,
                    labelColor: linkColor,
                    iconColor: linkColor,
                    selectedLabelColor: selectedLinkColor,
                    selectedIconColor: selectedLinkColor,
                    selectedBackgroundColor: style.selectedLinkBackgroundColor
                        ?.resolve(context),
                  ),
                ),
              ],
            ),
      centerTitle: links.isEmpty ? style.centerTitle : false,
      backgroundColor: style.backgroundColor?.resolve(context),
      foregroundColor: style.foregroundColor?.resolve(context),
      elevation: style.elevation,
      actions: actions.isEmpty && trailing.isEmpty
          ? null
          : [if (actions.isNotEmpty) FFActions(actions: actions), ...trailing],
      bottom: bottom,
      toolbarHeight: toolbarHeight,
    );
  }
}

/// Quita los destinos ocultos en [breakpoint] y los grupos que se quedan
/// sin subrutas visibles.
List<FFDestination> visibleDestinations(
  List<FFDestination> destinations,
  Breakpoint breakpoint,
) {
  bool shown(FFDestination d) => d.visible?.resolve(breakpoint) != false;
  return [
    for (final d in destinations)
      if (shown(d))
        if (!d.isGroup)
          d
        else if (d.children.any(shown))
          FFDestination(
            id: d.id,
            icon: d.icon,
            selectedIcon: d.selectedIcon,
            label: d.label,
            alwaysOpen: d.alwaysOpen,
            children: [
              for (final c in d.children)
                if (shown(c))
                  FFDestination(
                    id: c.id,
                    icon: c.icon,
                    selectedIcon: c.selectedIcon,
                    label: c.label,
                  ),
            ],
          ),
  ];
}

/// Logo y título de [brand] en una fila, para el app bar.
class FFBrandBar extends StatelessWidget {
  const FFBrandBar({super.key, required this.brand});

  final FFBrand brand;

  @override
  Widget build(BuildContext context) => brandTappable(
    brand.onTap,
    Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (brand.logo case final logo?) brandLogo(logo, 28),
        if (brand.logo != null && brand.title != null)
          const SizedBox(width: 10),
        ?brand.title,
      ],
    ),
  );
}

/// [logo] en un cuadrado de [size].
Widget brandLogo(Widget logo, double size) => SizedBox.square(
  dimension: size,
  child: FittedBox(child: logo),
);

/// [child] con efecto al tocar si hay [onTap].
Widget brandTappable(VoidCallback? onTap, Widget child) => onTap == null
    ? child
    : InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: child,
      );

/// Enlaces en fila, como en un sitio web. Un grupo es un botón con ▾ que
/// abre un dropdown con sus subrutas.
class FFNavLinks extends StatelessWidget {
  const FFNavLinks({
    super.key,
    required this.items,
    required this.currentRoute,
    required this.onSelected,
    this.labelColor,
    this.iconColor,
    this.selectedLabelColor,
    this.selectedIconColor,
    this.selectedBackgroundColor,
  });

  /// Ya filtrados con [visibleDestinations].
  final List<FFDestination> items;
  final String? currentRoute;
  final ValueChanged<String> onSelected;
  final Color? labelColor;
  final Color? iconColor;
  final Color? selectedLabelColor;
  final Color? selectedIconColor;
  final Color? selectedBackgroundColor;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final d in items)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: d.isGroup ? _group(context, d) : _link(context, d),
            ),
        ],
      ),
    ),
  );

  ButtonStyle _style(BuildContext context, {required bool selected}) {
    final scheme = Theme.of(context).colorScheme;
    return TextButton.styleFrom(
      foregroundColor: selected
          ? selectedLabelColor ?? scheme.onSecondaryContainer
          : labelColor ?? scheme.onSurfaceVariant,
      iconColor: selected
          ? selectedIconColor ?? scheme.onSecondaryContainer
          : iconColor ?? scheme.onSurfaceVariant,
      backgroundColor: selected
          ? selectedBackgroundColor ?? scheme.secondaryContainer
          : null,
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Widget _link(BuildContext context, FFDestination d) => TextButton(
    style: _style(context, selected: d.id == currentRoute),
    onPressed: () => onSelected(d.id),
    child: Text(d.label),
  );

  Widget _group(BuildContext context, FFDestination d) {
    final scheme = Theme.of(context).colorScheme;
    final selected = d.children.any((c) => c.id == currentRoute);
    return MenuAnchor(
      alignmentOffset: const Offset(0, 4),
      builder: (context, controller, _) => TextButton(
        style: _style(context, selected: selected),
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(d.label),
            const SizedBox(width: 4),
            AnimatedRotation(
              turns: controller.isOpen ? 0.5 : 0,
              duration: _duration,
              child: const Icon(Icons.expand_more, size: 18),
            ),
          ],
        ),
      ),
      menuChildren: [
        for (final c in d.children)
          MenuItemButton(
            leadingIcon: c.id == currentRoute
                ? c.selectedIcon ?? c.icon
                : c.icon,
            style: c.id == currentRoute
                ? MenuItemButton.styleFrom(
                    foregroundColor: selectedLabelColor ?? scheme.primary,
                    iconColor: selectedIconColor ?? scheme.primary,
                    backgroundColor: selectedBackgroundColor,
                  )
                : null,
            onPressed: () => onSelected(c.id),
            child: Text(c.label),
          ),
      ],
    );
  }
}
