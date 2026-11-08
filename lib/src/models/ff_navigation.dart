import 'package:flutter/widgets.dart';

import '../enums/breakpoint_enum.dart';
import '../enums/ff_navigation_enum.dart';
import '../enums/ff_rail_expand_enum.dart';
import 'ff_color.dart';
import 'ff_value.dart';

export '../enums/ff_navigation_enum.dart';
export '../enums/ff_rail_expand_enum.dart';

/// Appearance and behavior of an `FFScaffold`'s navigation at a breakpoint.
/// Used inside an `FFValue` with cascading behavior: each breakpoint defines
/// only what changes and inherits the rest from smaller breakpoints.
@immutable
class FFNavStyle {
  const FFNavStyle({
    this.type,
    this.expandMode,
    this.expanded,
    this.subRoutesAlwaysVisible,
    this.backgroundColor,
    this.iconColor,
    this.labelColor,
    this.selectedBackgroundColor,
    this.selectedIconColor,
    this.selectedLabelColor,
    this.shadow,
    this.shadowColor,
  });

  /// Bottom bar, rail, drawer, or links in the app bar.
  final FFNavigationEnum? type;

  /// For a rail, whether the full menu opens over the content or as a sidebar.
  final FFRailExpandEnum? expandMode;

  /// With [FFRailExpandEnum.sidebar], whether the menu starts open. Resets to
  /// this value when the breakpoint changes.
  final bool? expanded;

  /// Whether groups are always open, with no arrow.
  /// `FFDestination.alwaysOpen` takes precedence.
  final bool? subRoutesAlwaysVisible;

  /// Background of the bar, rail, and menu. With [FFNavigationEnum.appBar],
  /// used as the app bar background if it does not define one.
  final FFColor? backgroundColor;
  final FFColor? iconColor;
  final FFColor? labelColor;

  /// Background of the selected destination indicator.
  final FFColor? selectedBackgroundColor;
  final FFColor? selectedIconColor;
  final FFColor? selectedLabelColor;

  /// Shadow separating navigation from content: to the right of the rail and
  /// sidebar, and above the bar. No shadow by default.
  final bool? shadow;

  /// Shadow color. Defaults to a subtle `ColorScheme.shadow`.
  final FFColor? shadowColor;

  /// Values from [other] replace these values, except when they are `null`.
  FFNavStyle merge(FFNavStyle? other) {
    if (other == null) return this;
    return FFNavStyle(
      type: other.type ?? type,
      expandMode: other.expandMode ?? expandMode,
      expanded: other.expanded ?? expanded,
      subRoutesAlwaysVisible:
          other.subRoutesAlwaysVisible ?? subRoutesAlwaysVisible,
      backgroundColor: other.backgroundColor ?? backgroundColor,
      iconColor: other.iconColor ?? iconColor,
      labelColor: other.labelColor ?? labelColor,
      selectedBackgroundColor:
          other.selectedBackgroundColor ?? selectedBackgroundColor,
      selectedIconColor: other.selectedIconColor ?? selectedIconColor,
      selectedLabelColor: other.selectedLabelColor ?? selectedLabelColor,
      shadow: other.shadow ?? shadow,
      shadowColor: other.shadowColor ?? shadowColor,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is FFNavStyle &&
      other.type == type &&
      other.expandMode == expandMode &&
      other.expanded == expanded &&
      other.subRoutesAlwaysVisible == subRoutesAlwaysVisible &&
      other.backgroundColor == backgroundColor &&
      other.iconColor == iconColor &&
      other.labelColor == labelColor &&
      other.selectedBackgroundColor == selectedBackgroundColor &&
      other.selectedIconColor == selectedIconColor &&
      other.selectedLabelColor == selectedLabelColor &&
      other.shadow == shadow &&
      other.shadowColor == shadowColor;

  @override
  int get hashCode => Object.hash(
    type,
    expandMode,
    expanded,
    subRoutesAlwaysVisible,
    backgroundColor,
    iconColor,
    labelColor,
    selectedBackgroundColor,
    selectedIconColor,
    selectedLabelColor,
    shadow,
    shadowColor,
  );
}

/// Cascading merge of [FFNavStyle] values from an `FFValue`.
extension FFNavStyleValue on FFValue<FFNavStyle> {
  /// Merges styles from `xs` through [breakpoint]; larger breakpoints win.
  FFNavStyle resolveMerged(BreakpointEnum breakpoint) {
    var result = const FFNavStyle();
    for (var i = 0; i <= breakpoint.index; i++) {
      result = result.merge(at(BreakpointEnum.values[i]));
    }
    return result;
  }
}

/// A navigation destination. If it has [children], it is a group: it appears
/// as an accordion in the full menu and is not a page itself.
@immutable
class FFDestination {
  const FFDestination({
    required this.id,
    required this.icon,
    this.selectedIcon,
    required this.label,
    this.children = const [],
    this.visible,
    this.alwaysOpen,
  });

  /// Unique identifier, passed to `currentRoute` and `onRouteSelected`.
  final String id;
  final Widget icon;

  /// Icon when selected. If `null`, [icon] is used.
  final Widget? selectedIcon;
  final String label;

  /// Subroutes (one level only). Nested subroutes are ignored.
  final List<FFDestination> children;

  /// `false` hides it at that breakpoint. Visible by default.
  final FFValue<bool>? visible;

  /// Whether the group is always open, with no arrow to close it. If `null`,
  /// `FFNavStyle.subRoutesAlwaysVisible` is used.
  final bool? alwaysOpen;

  bool get isGroup => children.isNotEmpty;
}
