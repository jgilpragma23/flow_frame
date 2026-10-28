import 'package:flutter/widgets.dart';

import 'wr_value.dart';

/// Cómo se muestra un [WRAction] en un breakpoint.
enum WRActionDisplay {
  /// Ícono y texto, como botón.
  full,

  /// Solo el ícono; el texto queda como tooltip.
  icon,

  /// Dentro del menú ⋮, con ícono y texto.
  menu,

  /// No se muestra.
  hidden,
}

/// Una acción de un `WRActions`, como las del app bar.
@immutable
class WRAction {
  const WRAction({
    required this.icon,
    required this.label,
    this.onPressed,
    this.display,
  });

  final Widget icon;
  final String label;

  /// `null` la muestra deshabilitada.
  final VoidCallback? onPressed;

  /// Cómo se muestra en cada breakpoint, en cascada. Por defecto
  /// [WRActionDisplay.icon].
  final WRValue<WRActionDisplay>? display;
}
