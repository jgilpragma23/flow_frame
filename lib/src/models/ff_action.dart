import 'package:flutter/widgets.dart';

import 'ff_value.dart';

/// Cómo se muestra un [FFAction] en un breakpoint.
enum FFActionDisplay {
  /// Ícono y texto, como botón.
  full,

  /// Solo el ícono; el texto queda como tooltip.
  icon,

  /// Dentro del menú ⋮, con ícono y texto.
  menu,

  /// No se muestra.
  hidden,
}

/// Una acción de un `FFActions`, como las del app bar.
@immutable
class FFAction {
  const FFAction({
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
  /// [FFActionDisplay.icon].
  final FFValue<FFActionDisplay>? display;
}
