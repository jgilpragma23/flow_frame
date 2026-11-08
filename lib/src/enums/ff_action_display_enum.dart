/// How an [FFAction] is displayed at a breakpoint.
enum FFActionDisplayEnum {
  /// Icon and text, like a button.
  full,

  /// Icon only; the text is used as a tooltip.
  icon,

  /// In the ⋮ menu, with icon and text.
  menu,

  /// Hidden.
  hidden,
}
