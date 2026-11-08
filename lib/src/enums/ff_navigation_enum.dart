import 'ff_rail_expand_enum.dart';

/// Navigation type for an `FFScaffold`. Choose one per breakpoint.
enum FFNavigationEnum {
  /// Bottom bar with icons and labels (`NavigationBar`). Subroutes are not
  /// shown; tapping a group navigates to its last visited subroute (or the
  /// first one).
  bottom,

  /// Fixed icon rail with a ☰ button that opens the full menu over the
  /// content or pushes it, depending on [FFRailExpandEnum].
  rail,

  /// Hidden menu that slides in from the side when ☰ is tapped in the app bar.
  drawer,

  /// Links inside the app bar, after the title, like on a website. A group is
  /// a button with ▾ that opens a dropdown containing its subroutes.
  /// Intended for medium and large screens.
  appBar,
}
