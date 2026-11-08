import 'package:flutter/widgets.dart';

import '../models/breakpoint.dart';
import '../models/ff_value.dart';

extension FFContextExtensions on BuildContext {
  /// Current [BreakpointEnum], based on the screen width.
  BreakpointEnum get breakpoint =>
      BreakpointEnum.fromWidth(MediaQuery.sizeOf(this).width);

  /// Selects a value based on the current breakpoint (mobile-first cascade).
  T? responsive<T>({T? xs, T? sm, T? md, T? lg, T? xl}) =>
      FFValue<T>(xs: xs, sm: sm, md: md, lg: lg, xl: xl).resolve(breakpoint);
}
