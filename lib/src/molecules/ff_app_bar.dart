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

/// A standalone responsive `AppBar` for the `appBar` of any `Scaffold`,
/// without the `FFScaffold` layout.
///
/// Combines branding, a title, navigation links (with dropdown groups), and
/// actions that adapt per breakpoint. [responsive] can hide the entire bar
/// or its branding or title, and change its colors at each breakpoint.
///
/// Inside an `FFScaffold`, inherits any unspecified values: branding (if it
/// has no [title]), destinations and route for links with
/// `FFNavigationEnum.appBar`, and colors from `FFNavStyle`.
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

  /// App logo and name, at the beginning.
  final FFBrand? brand;

  /// After the branding, for example, the page name.
  final Widget? title;
  final Widget? leading;
  final bool automaticallyImplyLeading;

  /// Actions that adapt per breakpoint, as in `FFActions`.
  final List<FFAction> actions;

  /// Widgets after [actions], such as an avatar.
  final List<Widget> trailing;

  /// Links after the title. Shown only if [onRouteSelected] is provided;
  /// respects `FFDestination.visible`.
  final List<FFDestination> destinations;

  /// `id` of the current route, used to highlight its link.
  final String? currentRoute;
  final ValueChanged<String>? onRouteSelected;

  /// Visibility, branding, title, and colors per breakpoint, with cascading.
  final FFValue<FFAppBarStyle>? responsive;
  final PreferredSizeWidget? bottom;
  final double? toolbarHeight;

  @override
  Size get preferredSize => Size.fromHeight(
    (toolbarHeight ?? kToolbarHeight) + (bottom?.preferredSize.height ?? 0),
  );

  /// A copy with the provided values replaced.
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
    // When hidden, keep only the status bar space, which Scaffold no longer
    // adds to the body.
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
          SizedBox(
            width: 1,
            height: 24,
            child: ColoredBox(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
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
      centerTitle: links.isEmpty ? style.centerTitle ?? false : false,
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

/// Removes destinations hidden at [breakpoint] and groups with no visible
/// subroutes.
List<FFDestination> visibleDestinations(
  List<FFDestination> destinations,
  BreakpointEnum breakpoint,
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

/// Logo and title from [brand] in a row for the app bar.
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

/// Fits [logo] into a square of [size].
Widget brandLogo(Widget logo, double size) => SizedBox.square(
  dimension: size,
  child: FittedBox(child: logo),
);

/// Makes [child] tappable if [onTap] is provided.
Widget brandTappable(VoidCallback? onTap, Widget child) => onTap == null
    ? child
    : InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: child,
      );

/// Links in a row, like on a website. A group is a button with ▾ that opens a
/// dropdown containing its subroutes.
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

  /// Already filtered by [visibleDestinations].
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
