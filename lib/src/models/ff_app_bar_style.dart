import 'package:flutter/widgets.dart';

import 'breakpoint.dart';
import 'ff_color.dart';
import 'ff_value.dart';

/// Appearance of an `FFAppBar` at a breakpoint. Used inside an `FFValue` with
/// cascading behavior: each breakpoint defines only what changes and
/// inherits the rest from smaller breakpoints.
@immutable
class FFAppBarStyle {
  const FFAppBarStyle({
    this.visible,
    this.showBrand,
    this.showTitle,
    this.centerTitle,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.linkColor,
    this.selectedLinkColor,
    this.selectedLinkBackgroundColor,
  });

  /// `false` hides the entire app bar and moves the content up. Visible by
  /// default.
  final bool? visible;

  /// `false` hides the branding. Visible by default.
  final bool? showBrand;

  /// `false` hides the title. Visible by default.
  final bool? showTitle;

  /// Whether to center the branding and title. Defaults to left-aligned on
  /// all platforms; with links, they always remain left-aligned.
  final bool? centerTitle;
  final FFColor? backgroundColor;

  /// Color of the icons and title text.
  final FFColor? foregroundColor;
  final double? elevation;

  /// Link text and icons.
  final FFColor? linkColor;
  final FFColor? selectedLinkColor;

  /// Background of the current route's link.
  final FFColor? selectedLinkBackgroundColor;

  /// Values from [other] replace these values, except when they are `null`.
  FFAppBarStyle merge(FFAppBarStyle? other) {
    if (other == null) return this;
    return FFAppBarStyle(
      visible: other.visible ?? visible,
      showBrand: other.showBrand ?? showBrand,
      showTitle: other.showTitle ?? showTitle,
      centerTitle: other.centerTitle ?? centerTitle,
      backgroundColor: other.backgroundColor ?? backgroundColor,
      foregroundColor: other.foregroundColor ?? foregroundColor,
      elevation: other.elevation ?? elevation,
      linkColor: other.linkColor ?? linkColor,
      selectedLinkColor: other.selectedLinkColor ?? selectedLinkColor,
      selectedLinkBackgroundColor:
          other.selectedLinkBackgroundColor ?? selectedLinkBackgroundColor,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is FFAppBarStyle &&
      other.visible == visible &&
      other.showBrand == showBrand &&
      other.showTitle == showTitle &&
      other.centerTitle == centerTitle &&
      other.backgroundColor == backgroundColor &&
      other.foregroundColor == foregroundColor &&
      other.elevation == elevation &&
      other.linkColor == linkColor &&
      other.selectedLinkColor == selectedLinkColor &&
      other.selectedLinkBackgroundColor == selectedLinkBackgroundColor;

  @override
  int get hashCode => Object.hash(
    visible,
    showBrand,
    showTitle,
    centerTitle,
    backgroundColor,
    foregroundColor,
    elevation,
    linkColor,
    selectedLinkColor,
    selectedLinkBackgroundColor,
  );
}

/// Cascading merge of [FFAppBarStyle] values from an `FFValue`.
extension FFAppBarStyleValue on FFValue<FFAppBarStyle> {
  /// Merges styles from `xs` through [breakpoint]; larger breakpoints win.
  FFAppBarStyle resolveMerged(BreakpointEnum breakpoint) {
    var result = const FFAppBarStyle();
    for (var i = 0; i <= breakpoint.index; i++) {
      result = result.merge(at(BreakpointEnum.values[i]));
    }
    return result;
  }
}
