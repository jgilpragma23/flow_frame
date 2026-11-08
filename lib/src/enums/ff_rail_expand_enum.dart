/// How the full menu (with labels and accordion groups) opens from the rail.
enum FFRailExpandEnum {
  /// Opens a drawer over the content without moving it. Closes when a
  /// destination is selected or the area outside is tapped.
  overlay,

  /// The rail expands and pushes the content. It remains open until closed
  /// with ☰.
  sidebar,
}
