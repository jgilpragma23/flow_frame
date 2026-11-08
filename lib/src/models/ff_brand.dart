import 'package:flutter/widgets.dart';

/// App branding (logo and name) displayed alongside the ☰ button in an
/// `FFScaffold`. Define it once; each navigation type positions it:
///
/// - sidebar and overlay: logo, [title], and [subtitle] in the menu header;
/// - collapsed rail: only the [logo], below ☰;
/// - drawer: logo and [title] in the app bar, and full branding at the top of
///   the drawer (if [showInDrawer]);
/// - appBar: logo and [title] before the links;
/// - bottom: logo and [title] in the app bar.
///
/// In the app bar, branding is used only if the `AppBar` has no `title`; its
/// own title takes precedence.
@immutable
class FFBrand {
  const FFBrand({
    this.logo,
    this.title,
    this.subtitle,
    this.onTap,
    this.showInDrawer = true,
  }) : assert(logo != null || title != null);

  /// Icon or image; the only element displayed in a collapsed rail.
  final Widget? logo;
  final Widget? title;

  /// Below [title], only in the menu (sidebar, overlay, and drawer).
  final Widget? subtitle;

  /// For example, to navigate to the home page.
  final VoidCallback? onTap;

  /// With `FFNavigationEnum.drawer`, whether to repeat branding at the top of
  /// the drawer in addition to the app bar.
  final bool showInDrawer;
}
