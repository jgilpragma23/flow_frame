import 'package:flutter/widgets.dart';

import '../enums/ff_action_display_enum.dart';
import 'ff_value.dart';

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
  /// [FFActionDisplayEnum.icon].
  final FFValue<FFActionDisplayEnum>? display;
}
