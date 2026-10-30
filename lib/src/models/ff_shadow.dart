import 'package:flutter/painting.dart';

/// Sombras listas para `FFStyle.shadow`, como `shadow-sm`, `shadow` y
/// `shadow-lg` de Bootstrap. Se puede usar cualquier `List<BoxShadow>`.
abstract final class FFShadow {
  /// Sin sombra, para quitarla en un breakpoint mayor.
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
