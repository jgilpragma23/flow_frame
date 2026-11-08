import 'package:flutter/painting.dart';

/// Ready-to-use shadows for `FFStyle.shadow`, similar to Bootstrap's
/// `shadow-sm`, `shadow`, and `shadow-lg`. Any `List<BoxShadow>` can be used.
abstract final class FFShadow {
  /// No shadow, to remove it at a larger breakpoint.
  static const none = <BoxShadow>[];

  static const sm = [
    BoxShadow(color: Color(0x13000000), offset: Offset(0, 2), blurRadius: 4),
  ];

  static const md = [
    BoxShadow(color: Color(0x26000000), offset: Offset(0, 8), blurRadius: 16),
  ];

  static const lg = [
    BoxShadow(color: Color(0x2D000000), offset: Offset(0, 16), blurRadius: 48),
  ];
}
