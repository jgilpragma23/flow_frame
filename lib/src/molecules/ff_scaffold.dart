import 'package:flutter/material.dart';

import '../models/breakpoint.dart';
import '../models/ff_color.dart';
import '../models/ff_navigation.dart';
import '../models/ff_value.dart';
import '../utils/context_extensions.dart';

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

    final items = _visible(widget.destinations, breakpoint);
    _trackRoute(items);

    return Scaffold(
      key: _scaffoldKey,
      appBar: switch (_navigation) {
        FFNavigation.drawer => widget.appBar ?? AppBar(),
        FFNavigation.appBar => _appBarWithNav(items),
        _ => widget.appBar,
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
              child: SafeArea(child: _menu(items, closeOnSelect: true)),
            )
          : null,
      body: _navigation == FFNavigation.rail ? _railBody(items) : widget.body,
    );
  }

  /// Quita los ocultos y los grupos que se quedan sin subrutas visibles.
  List<FFDestination> _visible(
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
    final nav = Align(
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final d in items)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: d.isGroup ? _appBarGroup(d) : _appBarLink(d),
              ),
          ],
        ),
      ),
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

    final title = source.title;
    return AppBar(
      key: source.key,
      leading: source.leading,
      automaticallyImplyLeading: source.automaticallyImplyLeading,
      title: Row(
        children: [
          if (title != null) ...[title, const SizedBox(width: 24)],
          Expanded(child: nav),
        ],
      ),
      actions: source.actions,
      actionsPadding: source.actionsPadding,
      flexibleSpace: source.flexibleSpace,
      bottom: source.bottom,
      elevation: source.elevation,
      scrolledUnderElevation: source.scrolledUnderElevation,
      shadowColor: source.shadowColor,
      surfaceTintColor: source.surfaceTintColor,
      shape: source.shape,
      backgroundColor: source.backgroundColor ?? _color(_style.backgroundColor),
      foregroundColor: source.foregroundColor,
      iconTheme: source.iconTheme,
      actionsIconTheme: source.actionsIconTheme,
      primary: source.primary,
      centerTitle: false,
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

  ButtonStyle _linkStyle({required bool selected}) {
    final scheme = Theme.of(context).colorScheme;
    return TextButton.styleFrom(
      foregroundColor: selected
          ? _color(_style.selectedLabelColor) ?? scheme.onSecondaryContainer
          : _color(_style.labelColor) ?? scheme.onSurfaceVariant,
      iconColor: selected
          ? _color(_style.selectedIconColor) ?? scheme.onSecondaryContainer
          : _color(_style.iconColor) ?? scheme.onSurfaceVariant,
      backgroundColor: selected
          ? _color(_style.selectedBackgroundColor) ?? scheme.secondaryContainer
          : null,
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Widget _appBarLink(FFDestination d) {
    final selected = d.id == widget.currentRoute;
    return TextButton(
      style: _linkStyle(selected: selected),
      onPressed: () => widget.onRouteSelected(d.id),
      child: Text(d.label),
    );
  }

  /// Un grupo: botón con ▾ que abre un dropdown con sus subrutas.
  Widget _appBarGroup(FFDestination d) {
    final scheme = Theme.of(context).colorScheme;
    final selected = d.children.any((c) => c.id == widget.currentRoute);
    return MenuAnchor(
      alignmentOffset: const Offset(0, 4),
      builder: (context, controller, _) => TextButton(
        style: _linkStyle(selected: selected),
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
            leadingIcon: c.id == widget.currentRoute
                ? c.selectedIcon ?? c.icon
                : c.icon,
            style: c.id == widget.currentRoute
                ? MenuItemButton.styleFrom(
                    foregroundColor:
                        _color(_style.selectedLabelColor) ?? scheme.primary,
                    iconColor:
                        _color(_style.selectedIconColor) ?? scheme.primary,
                    backgroundColor: _color(_style.selectedBackgroundColor),
                  )
                : null,
            onPressed: () => widget.onRouteSelected(c.id),
            child: Text(c.label),
          ),
      ],
    );
  }

  Widget _railBody(List<FFDestination> items) {
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
                  color: background,
                  child: _menu(
                    items,
                    closeOnSelect: false,
                    header: _menuButton(open: true),
                  ),
                )
              : _collapsedRail(items),
        ),
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(child: widget.body),
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
    if (_expandMode == WRRailExpand.sidebar) return row;

    final scheme = Theme.of(context).colorScheme;
    return Stack(
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
              color: background ?? scheme.surfaceContainerLow,
              child: _menu(
                items,
                closeOnSelect: true,
                header: _menuButton(open: true),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _menuButton({required bool open}) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 0, 0, 8),
    child: Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        tooltip: open ? 'Cerrar menú' : 'Abrir menú',
        color: _color(_style.iconColor),
        icon: Icon(open ? Icons.menu_open : Icons.menu),
        onPressed: open ? closeMenu : openMenu,
      ),
    ),
  );

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
      leading: IconButton(
        tooltip: 'Abrir menú',
        color: _color(_style.iconColor),
        icon: const Icon(Icons.menu),
        onPressed: openMenu,
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
