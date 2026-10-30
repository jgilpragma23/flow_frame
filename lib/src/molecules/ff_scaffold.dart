import 'package:flutter/material.dart';

import '../models/breakpoint.dart';
import '../models/ff_app_bar_style.dart';
import '../models/ff_brand.dart';
import '../models/ff_color.dart';
import '../models/ff_navigation.dart';
import '../models/ff_value.dart';
import '../utils/context_extensions.dart';
import 'ff_app_bar.dart';

/// Un `Scaffold` cuya navegación cambia según el breakpoint: barra abajo,
/// rail lateral o drawer, con subrutas en acordeón en el menú completo.
///
/// Recibe los mismos parámetros principales que `Scaffold` y los pasa tal
/// cual. La ruta se identifica por `id`, así que no cambia al cambiar de
/// navegación ni al ocultarse destinos.
class FFScaffold extends StatefulWidget {
  const FFScaffold({
    super.key,
    required this.destinations,
    required this.currentRoute,
    required this.onRouteSelected,
    this.responsive,
    this.brand,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.backgroundColor,
  });

  /// Lo que se usa en lo que [responsive] no define: barra abajo en
  /// `xs`/`sm`, rail con el menú encima en `md` y rail con el menú abierto
  /// como sidebar desde `lg`.
  static const defaults = FFValue(
    xs: FFNavStyle(
      type: FFNavigation.bottom,
      expandMode: WRRailExpand.overlay,
      expanded: false,
      subRoutesAlwaysVisible: false,
    ),
    md: FFNavStyle(type: FFNavigation.rail),
    lg: FFNavStyle(expandMode: WRRailExpand.sidebar, expanded: true),
  );

  final List<FFDestination> destinations;

  /// `id` de la ruta actual (puede ser una subruta).
  final String currentRoute;

  /// Recibe el `id` elegido. Nunca recibe el `id` de un grupo.
  final ValueChanged<String> onRouteSelected;

  /// Tipo, comportamiento y colores de la navegación por breakpoint, en
  /// cascada. Lo que no se define sale de [defaults].
  final FFValue<FFNavStyle>? responsive;

  /// Logo y nombre de la app junto al ☰. Ver [FFBrand] para dónde aparece
  /// en cada tipo de navegación.
  final FFBrand? brand;

  /// Con [FFNavigation.drawer] muestra el botón ☰. Si es `null` y la
  /// navegación es drawer, se usa un `AppBar` vacío para tener el botón.
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Color? backgroundColor;

  /// El estado del [FFScaffold] más cercano, para abrir o cerrar el menú.
  static WRScaffoldState of(BuildContext context) =>
      context.findAncestorStateOfType<WRScaffoldState>()!;

  @override
  State<FFScaffold> createState() => WRScaffoldState();
}

class WRScaffoldState extends State<FFScaffold> {
  static const _menuWidth = 280.0;
  static const _duration = Duration(milliseconds: 220);

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Breakpoint? _breakpoint;
  FFNavStyle _style = const FFNavStyle();

  FFNavigation get _navigation => _style.type ?? FFNavigation.bottom;
  WRRailExpand get _expandMode => _style.expandMode ?? WRRailExpand.overlay;
  bool get _expandedByDefault => _style.expanded ?? false;

  /// Lo que eligió el usuario con ☰ en modo sidebar; se descarta al cambiar
  /// de breakpoint.
  bool? _sidebarOpen;
  bool _overlayOpen = false;

  final Set<String> _openGroups = {};
  final Map<String, String> _lastChild = {};
  String? _trackedRoute;

  /// Si el menú completo (con textos) está abierto.
  bool get isMenuOpen => switch (_navigation) {
    FFNavigation.bottom || FFNavigation.appBar => false,
    FFNavigation.drawer => _scaffoldKey.currentState?.isDrawerOpen ?? false,
    FFNavigation.rail =>
      _expandMode == WRRailExpand.overlay
          ? _overlayOpen
          : _sidebarOpen ?? _expandedByDefault,
  };

  void openMenu() => _setMenu(true);
  void closeMenu() => _setMenu(false);
  void toggleMenu() => _setMenu(!isMenuOpen);

  void _setMenu(bool open) {
    switch (_navigation) {
      case FFNavigation.bottom || FFNavigation.appBar:
        break;
      case FFNavigation.drawer:
        open
            ? _scaffoldKey.currentState?.openDrawer()
            : _scaffoldKey.currentState?.closeDrawer();
      case FFNavigation.rail:
        setState(() {
          if (_expandMode == WRRailExpand.overlay) {
            _overlayOpen = open;
          } else {
            _sidebarOpen = open;
          }
        });
    }
  }

  Color? _color(FFColor? color) => color?.resolve(context);

  @override
  Widget build(BuildContext context) {
    final breakpoint = context.breakpoint;
    if (breakpoint != _breakpoint) {
      _breakpoint = breakpoint;
      _sidebarOpen = null;
      _overlayOpen = false;
    }
    _style = FFScaffold.defaults
        .resolveMerged(breakpoint)
        .merge(widget.responsive?.resolveMerged(breakpoint));

    final items = visibleDestinations(widget.destinations, breakpoint);
    _trackRoute(items);

    final scaffold = Scaffold(
      key: _scaffoldKey,
      appBar: switch (_navigation) {
        _ when widget.appBar is FFAppBar => _adapt(widget.appBar! as FFAppBar),
        FFNavigation.drawer => _appBarWithBrand(widget.appBar ?? AppBar()),
        FFNavigation.appBar => _appBarWithNav(items),
        FFNavigation.bottom => _appBarWithBrand(widget.appBar),
        FFNavigation.rail => widget.appBar,
      },
      backgroundColor: widget.backgroundColor,
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation: widget.floatingActionButtonLocation,
      bottomNavigationBar: _navigation == FFNavigation.bottom
          ? _bottomBar(items)
          : null,
      drawer: _navigation == FFNavigation.drawer
          ? Drawer(
              width: _menuWidth + 24,
              backgroundColor: _color(_style.backgroundColor),
              child: SafeArea(
                child: _menu(
                  items,
                  closeOnSelect: true,
                  header: widget.brand?.showInDrawer ?? false
                      ? _drawerHeader()
                      : null,
                ),
              ),
            )
          : null,
      body: widget.body,
    );
    // El rail y el sidebar van por fuera del Scaffold para ocupar toda la
    // altura; el app bar queda solo sobre el contenido.
    return _navigation == FFNavigation.rail
        ? _railLayout(items, scaffold)
        : scaffold;
  }

  /// Alto del app bar, para alinear el ☰ del rail y del menú con él.
  double get _toolbarHeight {
    final height = switch (widget.appBar) {
      final AppBar bar => bar.toolbarHeight,
      final FFAppBar bar => bar.toolbarHeight,
      _ => null,
    };
    if (height != null) return height;
    return Theme.of(context).appBarTheme.toolbarHeight ?? kToolbarHeight;
  }

  /// Recuerda la última subruta de cada grupo y abre el grupo de la ruta
  /// actual cuando esta cambia.
  void _trackRoute(List<FFDestination> items) {
    if (widget.currentRoute == _trackedRoute) return;
    _trackedRoute = widget.currentRoute;
    final group = _groupOf(items, widget.currentRoute);
    if (group != null && group.isGroup) {
      _lastChild[group.id] = widget.currentRoute;
      _openGroups.add(group.id);
    }
  }

  /// El destino de primer nivel que es o contiene [id].
  FFDestination? _groupOf(List<FFDestination> items, String id) {
    for (final d in items) {
      if (d.id == id || d.children.any((c) => c.id == id)) return d;
    }
    return null;
  }

  bool _isAlwaysOpen(FFDestination group) =>
      group.alwaysOpen ?? _style.subRoutesAlwaysVisible ?? false;

  bool _isOpen(FFDestination group) =>
      _isAlwaysOpen(group) || _openGroups.contains(group.id);

  /// Para la barra y el rail cerrado: un grupo va a su última subruta
  /// visitada (o a la primera).
  String _targetOf(FFDestination d) {
    if (!d.isGroup) return d.id;
    final last = _lastChild[d.id];
    return d.children.any((c) => c.id == last) ? last! : d.children.first.id;
  }

  void _pick(String id, {required bool closeMenu}) {
    widget.onRouteSelected(id);
    if (closeMenu) this.closeMenu();
  }

  Color get _shadowColor {
    final theme = Theme.of(context);
    return _color(_style.shadowColor) ??
        theme.colorScheme.shadow.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.5 : 0.12,
        );
  }

  Widget _bottomBar(List<FFDestination> items) {
    final bar = _navigationBar(items);
    if (!(_style.shadow ?? false)) return bar;
    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: _shadowColor,
            blurRadius: 8,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: bar,
    );
  }

  Widget _navigationBar(List<FFDestination> items) {
    final selected = _groupOf(items, widget.currentRoute);
    final icon = _color(_style.iconColor);
    final selectedIcon = _color(_style.selectedIconColor);
    final label = _color(_style.labelColor);
    final selectedLabel = _color(_style.selectedLabelColor);
    return NavigationBar(
      backgroundColor: _color(_style.backgroundColor),
      indicatorColor: _color(_style.selectedBackgroundColor),
      selectedIndex: selected == null ? 0 : items.indexOf(selected),
      onDestinationSelected: (i) => widget.onRouteSelected(_targetOf(items[i])),
      destinations: [
        for (final d in items)
          NavigationDestination(
            icon: IconTheme.merge(
              data: IconThemeData(color: icon),
              child: d.icon,
            ),
            selectedIcon: IconTheme.merge(
              data: IconThemeData(color: selectedIcon),
              child: d.selectedIcon ?? d.icon,
            ),
            label: d.label,
          ),
      ],
      labelTextStyle: label == null && selectedLabel == null
          ? null
          : WidgetStateProperty.resolveWith(
              (states) => TextStyle(
                color: states.contains(WidgetState.selected)
                    ? selectedLabel
                    : label,
              ),
            ),
    );
  }

  /// El app bar del usuario con los enlaces después del título. Si no es un
  /// `AppBar`, los enlaces van en una franja debajo.
  PreferredSizeWidget _appBarWithNav(List<FFDestination> items) {
    final source = widget.appBar ?? AppBar();
    final nav = FFNavLinks(
      items: items,
      currentRoute: widget.currentRoute,
      onSelected: widget.onRouteSelected,
      labelColor: _color(_style.labelColor),
      iconColor: _color(_style.iconColor),
      selectedLabelColor: _color(_style.selectedLabelColor),
      selectedIconColor: _color(_style.selectedIconColor),
      selectedBackgroundColor: _color(_style.selectedBackgroundColor),
    );

    if (source is! AppBar) {
      return PreferredSize(
        preferredSize: Size.fromHeight(
          source.preferredSize.height + kToolbarHeight,
        ),
        child: Column(
          children: [
            source,
            Material(
              color: _color(_style.backgroundColor),
              child: SizedBox(height: kToolbarHeight, child: nav),
            ),
          ],
        ),
      );
    }

    final title = source.title ?? _brandBar;
    return _copyAppBar(
      source,
      title: Row(
        children: [
          if (title != null) ...[title, const SizedBox(width: 24)],
          Expanded(child: nav),
        ],
      ),
      centerTitle: false,
      backgroundColor: source.backgroundColor ?? _color(_style.backgroundColor),
    );
  }

  /// El app bar con la marca como título, si es un `AppBar` sin título.
  PreferredSizeWidget? _appBarWithBrand(PreferredSizeWidget? source) {
    final brand = _brandBar;
    if (source is! AppBar || source.title != null || brand == null) {
      return source;
    }
    return _copyAppBar(source, title: brand);
  }

  /// La marca para el app bar; `null` sin marca.
  Widget? get _brandBar =>
      widget.brand == null ? null : FFBrandBar(brand: widget.brand!);

  /// Un [FFAppBar] con lo que no define tomado de este scaffold: la marca
  /// (si no tiene título y la navegación no es rail), los destinos con
  /// [FFNavigation.appBar] y los colores de la navegación como base.
  FFAppBar _adapt(FFAppBar bar) {
    final linksInBar = _navigation == FFNavigation.appBar;
    final base = FFAppBarStyle(
      backgroundColor: linksInBar ? _style.backgroundColor : null,
      linkColor: _style.labelColor,
      selectedLinkColor: _style.selectedLabelColor,
      selectedLinkBackgroundColor: _style.selectedBackgroundColor,
    );
    final own = bar.responsive;
    return bar.copyWith(
      brand:
          bar.brand == null &&
              bar.title == null &&
              _navigation != FFNavigation.rail
          ? widget.brand
          : null,
      destinations: linksInBar && bar.destinations.isEmpty
          ? widget.destinations
          : null,
      currentRoute: bar.currentRoute == null ? widget.currentRoute : null,
      onRouteSelected: linksInBar && bar.onRouteSelected == null
          ? widget.onRouteSelected
          : null,
      // La base va en xs para que cualquier breakpoint del app bar la pise.
      responsive: FFValue(
        xs: base.merge(own?.xs),
        sm: own?.sm,
        md: own?.md,
        lg: own?.lg,
        xl: own?.xl,
      ),
    );
  }

  /// Copia de [source] con otro título.
  AppBar _copyAppBar(
    AppBar source, {
    required Widget title,
    bool? centerTitle,
    Color? backgroundColor,
  }) {
    return AppBar(
      key: source.key,
      leading: source.leading,
      automaticallyImplyLeading: source.automaticallyImplyLeading,
      title: title,
      actions: source.actions,
      actionsPadding: source.actionsPadding,
      flexibleSpace: source.flexibleSpace,
      bottom: source.bottom,
      elevation: source.elevation,
      scrolledUnderElevation: source.scrolledUnderElevation,
      shadowColor: source.shadowColor,
      surfaceTintColor: source.surfaceTintColor,
      shape: source.shape,
      backgroundColor: backgroundColor ?? source.backgroundColor,
      foregroundColor: source.foregroundColor,
      iconTheme: source.iconTheme,
      actionsIconTheme: source.actionsIconTheme,
      primary: source.primary,
      centerTitle: centerTitle ?? source.centerTitle,
      titleSpacing: source.titleSpacing,
      toolbarHeight: source.toolbarHeight,
      leadingWidth: source.leadingWidth,
      toolbarTextStyle: source.toolbarTextStyle,
      titleTextStyle: source.titleTextStyle,
      systemOverlayStyle: source.systemOverlayStyle,
      forceMaterialTransparency: source.forceMaterialTransparency,
      clipBehavior: source.clipBehavior,
    );
  }

  Widget _railLayout(List<FFDestination> items, Widget content) {
    final theme = Theme.of(context);
    final background = _color(_style.backgroundColor);
    final sidebarOpen =
        _expandMode == WRRailExpand.sidebar &&
        (_sidebarOpen ?? _expandedByDefault);

    final row = Row(
      children: [
        AnimatedSize(
          duration: _duration,
          curve: Curves.easeOut,
          alignment: Alignment.centerLeft,
          child: sidebarOpen
              ? Container(
                  width: _menuWidth,
                  color: background ?? theme.colorScheme.surface,
                  child: _menuWithHeader(items, closeOnSelect: false),
                )
              : ColoredBox(
                  color: background ?? theme.colorScheme.surface,
                  child: SafeArea(right: false, child: _collapsedRail(items)),
                ),
        ),
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(child: content),
              // Encima del contenido, para que un fondo propio no la tape.
              if (_style.shadow ?? false)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 8,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _shadowColor,
                            _shadowColor.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
    if (_expandMode == WRRailExpand.sidebar) {
      return Material(
        color: widget.backgroundColor ?? theme.scaffoldBackgroundColor,
        child: row,
      );
    }

    return Material(
      color: widget.backgroundColor ?? theme.scaffoldBackgroundColor,
      child: Stack(
        children: [
          Positioned.fill(child: row),
          Positioned.fill(
            child: IgnorePointer(
              ignoring: !_overlayOpen,
              child: AnimatedOpacity(
                opacity: _overlayOpen ? 1 : 0,
                duration: _duration,
                child: GestureDetector(
                  onTap: closeMenu,
                  child: const ColoredBox(color: Colors.black38),
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: _duration,
            curve: Curves.easeOut,
            top: 0,
            bottom: 0,
            left: _overlayOpen ? 0 : -(_menuWidth + 24),
            width: _menuWidth + 24,
            child: Offstage(
              offstage: !_overlayOpen,
              child: Material(
                elevation: 1,
                color: background ?? theme.colorScheme.surfaceContainerLow,
                child: _menuWithHeader(items, closeOnSelect: true),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// El menú del sidebar y del overlay, con [_menuHeader] fijo arriba a la
  /// altura del app bar.
  Widget _menuWithHeader(
    List<FFDestination> items, {
    required bool closeOnSelect,
  }) => SafeArea(
    right: false,
    child: Column(
      children: [
        SizedBox(height: _toolbarHeight, child: _menuHeader()),
        Expanded(child: _menu(items, closeOnSelect: closeOnSelect)),
      ],
    ),
  );

  /// ☰ para cerrar el menú, con la marca al lado.
  Widget _menuHeader() => Padding(
    padding: const EdgeInsets.only(left: 16, right: 12),
    child: Row(
      children: [
        IconButton(
          tooltip: 'Cerrar menú',
          color: _color(_style.iconColor),
          icon: const Icon(Icons.menu_open),
          onPressed: closeMenu,
        ),
        if (widget.brand case final brand?) ...[
          const SizedBox(width: 4),
          Expanded(child: _brandTile(brand, subtitle: true)),
        ],
      ],
    ),
  );

  /// Arriba dentro del drawer: la marca con su subtítulo y una línea.
  Widget _drawerHeader() => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 0, 12),
          child: _brandTile(widget.brand!, subtitle: true, logoSize: 32),
        ),
        const Divider(height: 1),
      ],
    ),
  );

  /// Logo, título y subtítulo para el menú, con los colores del estilo.
  Widget _brandTile(
    FFBrand brand, {
    required bool subtitle,
    double logoSize = 28,
  }) {
    final theme = Theme.of(context);
    final label = _color(_style.labelColor);
    return brandTappable(
      brand.onTap,
      Row(
        children: [
          if (brand.logo case final logo?) brandLogo(logo, logoSize),
          if (brand.logo != null) const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (brand.title case final title?)
                  DefaultTextStyle.merge(
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: label ?? theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    child: title,
                  ),
                if (subtitle && brand.subtitle != null)
                  DefaultTextStyle.merge(
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: label ?? theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    child: brand.subtitle!,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _collapsedRail(List<FFDestination> items) {
    final selected = _groupOf(items, widget.currentRoute);
    final label = _color(_style.labelColor);
    final selectedLabel = _color(_style.selectedLabelColor);
    return NavigationRail(
      scrollable: true,
      backgroundColor: _color(_style.backgroundColor),
      indicatorColor: _color(_style.selectedBackgroundColor),
      unselectedIconTheme: IconThemeData(color: _color(_style.iconColor)),
      selectedIconTheme: IconThemeData(color: _color(_style.selectedIconColor)),
      unselectedLabelTextStyle: label == null ? null : TextStyle(color: label),
      selectedLabelTextStyle: selectedLabel == null
          ? null
          : TextStyle(color: selectedLabel),
      selectedIndex: selected == null ? null : items.indexOf(selected),
      onDestinationSelected: (i) {
        final d = items[i];
        if (!d.isGroup) return widget.onRouteSelected(d.id);
        // Un grupo abre el menú completo con ese grupo desplegado.
        _openGroups.add(d.id);
        openMenu();
      },
      leading: Column(
        children: [
          // El rail ya deja 8 arriba; el ☰ (40 de alto) queda centrado con
          // el título del app bar.
          SizedBox(
            height: _toolbarHeight - 8,
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(
                  top: (_toolbarHeight / 2 - 28).clamp(0, double.infinity),
                ),
                child: IconButton(
                  tooltip: 'Abrir menú',
                  visualDensity: VisualDensity.compact,
                  color: _color(_style.iconColor),
                  icon: const Icon(Icons.menu),
                  onPressed: openMenu,
                ),
              ),
            ),
          ),
          if (widget.brand?.logo case final logo?) ...[
            const SizedBox(height: 8),
            brandTappable(widget.brand!.onTap, brandLogo(logo, 32)),
          ],
        ],
      ),
      destinations: [
        for (final d in items)
          NavigationRailDestination(
            icon: Tooltip(message: d.label, child: d.icon),
            selectedIcon: Tooltip(
              message: d.label,
              child: d.selectedIcon ?? d.icon,
            ),
            label: Text(d.label),
          ),
      ],
    );
  }

  /// Menú completo con textos y acordeón (sidebar, overlay y drawer).
  Widget _menu(
    List<FFDestination> items, {
    required bool closeOnSelect,
    Widget? header,
  }) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      children: [
        ?header,
        for (final d in items) ...[
          if (!d.isGroup)
            _tile(
              destination: d,
              selected: d.id == widget.currentRoute,
              onTap: () => _pick(d.id, closeMenu: closeOnSelect),
            )
          else ...[
            _tile(
              destination: d,
              selected: false,
              emphasized: d.children.any((c) => c.id == widget.currentRoute),
              onTap: _isAlwaysOpen(d)
                  ? null
                  : () => setState(() {
                      if (!_openGroups.remove(d.id)) _openGroups.add(d.id);
                    }),
              trailing: _isAlwaysOpen(d)
                  ? null
                  : AnimatedRotation(
                      turns: _isOpen(d) ? 0.5 : 0,
                      duration: _duration,
                      child: const Icon(Icons.expand_more),
                    ),
            ),
            ClipRect(
              child: AnimatedSize(
                duration: _duration,
                curve: Curves.easeOut,
                alignment: Alignment.topCenter,
                child: _isOpen(d)
                    ? Column(
                        children: [
                          for (final c in d.children)
                            _tile(
                              destination: c,
                              child: true,
                              selected: c.id == widget.currentRoute,
                              onTap: () =>
                                  _pick(c.id, closeMenu: closeOnSelect),
                            ),
                        ],
                      )
                    : const SizedBox(width: double.infinity),
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _tile({
    required FFDestination destination,
    required bool selected,
    bool emphasized = false,
    bool child = false,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    // Un grupo con la ruta actual adentro usa los colores de seleccionado,
    // pero sin fondo.
    final iconColor = selected || emphasized
        ? _color(_style.selectedIconColor) ??
              (selected ? scheme.onSecondaryContainer : scheme.primary)
        : _color(_style.iconColor) ?? scheme.onSurfaceVariant;
    final labelColor = selected || emphasized
        ? _color(_style.selectedLabelColor) ??
              (selected ? scheme.onSecondaryContainer : scheme.primary)
        : _color(_style.labelColor) ?? scheme.onSurfaceVariant;
    final icon = selected
        ? destination.selectedIcon ?? destination.icon
        : destination.icon;

    return Padding(
      padding: EdgeInsets.only(left: child ? 16 : 0, bottom: 2),
      child: Material(
        color: selected
            ? _color(_style.selectedBackgroundColor) ??
                  scheme.secondaryContainer
            : Colors.transparent,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: child ? 44 : 52,
            child: Row(
              children: [
                const SizedBox(width: 16),
                IconTheme.merge(
                  data: IconThemeData(color: iconColor, size: child ? 20 : 24),
                  child: icon,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    destination.label,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: labelColor,
                      fontWeight: selected || emphasized
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                ),
                if (trailing != null)
                  IconTheme.merge(
                    data: IconThemeData(color: labelColor),
                    child: trailing,
                  ),
                const SizedBox(width: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
