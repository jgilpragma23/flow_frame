import 'package:flutter/material.dart';

import '../models/breakpoint.dart';
import '../models/ff_app_bar_style.dart';
import '../models/ff_brand.dart';
import '../models/ff_color.dart';
import '../models/ff_navigation.dart';
import '../models/ff_value.dart';
import '../utils/context_extensions.dart';
import 'ff_app_bar.dart';

/// A `Scaffold` whose navigation adapts per breakpoint: bottom bar, side rail,
/// or drawer, with subroutes in an accordion in the full menu.
///
/// Accepts the same main parameters as `Scaffold` and passes them through.
/// Routes are identified by `id`, so they do not change when navigation
/// changes or destinations are hidden.
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

  /// Values used when [responsive] does not define them: bottom bar on
  /// `xs`/`sm`, rail with the menu overlaid on `md`, and rail with the menu
  /// open as a sidebar from `lg`.
  static const defaults = FFValue(
    xs: FFNavStyle(
      type: FFNavigationEnum.bottom,
      expandMode: FFRailExpandEnum.overlay,
      expanded: false,
      subRoutesAlwaysVisible: false,
    ),
    md: FFNavStyle(type: FFNavigationEnum.rail),
    lg: FFNavStyle(expandMode: FFRailExpandEnum.sidebar, expanded: true),
  );

  final List<FFDestination> destinations;

  /// `id` of the current route (may be a subroute).
  final String currentRoute;

  /// Receives the selected `id`. Never receives a group's `id`.
  final ValueChanged<String> onRouteSelected;

  /// Navigation type, behavior, and colors per breakpoint, with cascading.
  /// Unspecified values come from [defaults].
  final FFValue<FFNavStyle>? responsive;

  /// App logo and name next to ☰. See [FFBrand] for its position with each
  /// navigation type.
  final FFBrand? brand;

  /// Displays the ☰ button with [FFNavigationEnum.drawer]. If `null` and
  /// navigation uses a drawer, an empty `AppBar` is used to provide the
  /// button.
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Color? backgroundColor;

  /// State of the nearest [FFScaffold], used to open or close the menu.
  static FFScaffoldState of(BuildContext context) =>
      context.findAncestorStateOfType<FFScaffoldState>()!;

  @override
  State<FFScaffold> createState() => FFScaffoldState();
}

class FFScaffoldState extends State<FFScaffold> {
  static const _menuWidth = 280.0;
  static const _duration = Duration(milliseconds: 220);

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  BreakpointEnum? _breakpoint;
  FFNavStyle _style = const FFNavStyle();

  FFNavigationEnum get _navigation => _style.type ?? FFNavigationEnum.bottom;
  FFRailExpandEnum get _expandMode =>
      _style.expandMode ?? FFRailExpandEnum.overlay;
  bool get _expandedByDefault => _style.expanded ?? false;

  /// What the user selected with ☰ in sidebar mode; discarded when the
  /// breakpoint changes.
  bool? _sidebarOpen;
  bool _overlayOpen = false;

  final Set<String> _openGroups = {};
  final Map<String, String> _lastChild = {};
  String? _trackedRoute;

  /// Whether the full menu (with labels) is open.
  bool get isMenuOpen => switch (_navigation) {
    FFNavigationEnum.bottom || FFNavigationEnum.appBar => false,
    FFNavigationEnum.drawer => _scaffoldKey.currentState?.isDrawerOpen ?? false,
    FFNavigationEnum.rail =>
      _expandMode == FFRailExpandEnum.overlay
          ? _overlayOpen
          : _sidebarOpen ?? _expandedByDefault,
  };

  void openMenu() => _setMenu(true);
  void closeMenu() => _setMenu(false);
  void toggleMenu() => _setMenu(!isMenuOpen);

  void _setMenu(bool open) {
    switch (_navigation) {
      case FFNavigationEnum.bottom || FFNavigationEnum.appBar:
        break;
      case FFNavigationEnum.drawer:
        open
            ? _scaffoldKey.currentState?.openDrawer()
            : _scaffoldKey.currentState?.closeDrawer();
      case FFNavigationEnum.rail:
        setState(() {
          if (_expandMode == FFRailExpandEnum.overlay) {
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
        FFNavigationEnum.drawer => _appBarWithBrand(widget.appBar ?? AppBar()),
        FFNavigationEnum.appBar => _appBarWithNav(items),
        FFNavigationEnum.bottom => _appBarWithBrand(widget.appBar),
        FFNavigationEnum.rail => widget.appBar,
      },
      backgroundColor: widget.backgroundColor,
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation: widget.floatingActionButtonLocation,
      bottomNavigationBar: _navigation == FFNavigationEnum.bottom
          ? _bottomBar(items)
          : null,
      drawer: _navigation == FFNavigationEnum.drawer
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
    // Keep the rail and sidebar outside the Scaffold so they use the full
    // height; the app bar remains above the content only.
    return _navigation == FFNavigationEnum.rail
        ? _railLayout(items, scaffold)
        : scaffold;
  }

  /// App bar height, used to align ☰ in the rail and menu with it.
  double get _toolbarHeight {
    final height = switch (widget.appBar) {
      final AppBar bar => bar.toolbarHeight,
      final FFAppBar bar => bar.toolbarHeight,
      _ => null,
    };
    if (height != null) return height;
    return Theme.of(context).appBarTheme.toolbarHeight ?? kToolbarHeight;
  }

  /// Remembers each group's last subroute and opens the group containing the
  /// current route when it changes.
  void _trackRoute(List<FFDestination> items) {
    if (widget.currentRoute == _trackedRoute) return;
    _trackedRoute = widget.currentRoute;
    final group = _groupOf(items, widget.currentRoute);
    if (group != null && group.isGroup) {
      _lastChild[group.id] = widget.currentRoute;
      _openGroups.add(group.id);
    }
  }

  /// The top-level destination that is or contains [id].
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

  /// For the bar and collapsed rail: a group navigates to its last visited
  /// subroute (or the first one).
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

  /// User-provided app bar with links after the title. If it is not an
  /// `AppBar`, links appear in a strip below it.
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

  /// App bar with branding as the title, if it is an `AppBar` without a title.
  PreferredSizeWidget? _appBarWithBrand(PreferredSizeWidget? source) {
    final brand = _brandBar;
    if (source is! AppBar || source.title != null || brand == null) {
      return source;
    }
    return _copyAppBar(source, title: brand);
  }

  /// Branding for the app bar; `null` if there is no branding.
  Widget? get _brandBar =>
      widget.brand == null ? null : FFBrandBar(brand: widget.brand!);

  /// An [FFAppBar] that inherits any unspecified values from this scaffold:
  /// branding (if it has no title and navigation is not a rail), destinations
  /// with [FFNavigationEnum.appBar], and navigation colors as a base.
  FFAppBar _adapt(FFAppBar bar) {
    final linksInBar = _navigation == FFNavigationEnum.appBar;
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
              _navigation != FFNavigationEnum.rail
          ? widget.brand
          : null,
      destinations: linksInBar && bar.destinations.isEmpty
          ? widget.destinations
          : null,
      currentRoute: bar.currentRoute == null ? widget.currentRoute : null,
      onRouteSelected: linksInBar && bar.onRouteSelected == null
          ? widget.onRouteSelected
          : null,
      // Set the base at xs so any app bar breakpoint can override it.
      responsive: FFValue(
        xs: base.merge(own?.xs),
        sm: own?.sm,
        md: own?.md,
        lg: own?.lg,
        xl: own?.xl,
      ),
    );
  }

  /// Copy of [source] with a different title.
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
        _expandMode == FFRailExpandEnum.sidebar &&
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
              // Keep it over the content so a custom background does not hide it.
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
    if (_expandMode == FFRailExpandEnum.sidebar) {
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

  /// Sidebar and overlay menu, with [_menuHeader] fixed at the top at app bar
  /// height.
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

  /// ☰ button to close the menu, with branding alongside it.
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

  /// Top of the drawer: branding with its subtitle and a divider.
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

  /// Logo, title, and subtitle for the menu, using the style's colors.
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
        // A group opens the full menu with that group expanded.
        _openGroups.add(d.id);
        openMenu();
      },
      leading: Column(
        children: [
          // The rail already has 8 px of top padding; the 40 px ☰ button
          // aligns with the app bar title.
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

  /// Full menu with labels and accordion groups (sidebar, overlay, and drawer).
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
    // A group containing the current route uses selected colors, but no
    // background.
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
