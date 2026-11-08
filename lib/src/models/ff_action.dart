import 'package:flutter/widgets.dart';

import '../enums/ff_action_display_enum.dart';
import 'ff_value.dart';

/// An action in `FFActions`, such as an app bar action.
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

  /// `null` displays it as disabled.
  final VoidCallback? onPressed;

  /// How it is displayed at each breakpoint, with cascading behavior.
  /// Defaults to [FFActionDisplayEnum.icon].
  final FFValue<FFActionDisplayEnum>? display;
}
