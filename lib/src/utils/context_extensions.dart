import 'package:flutter/widgets.dart';

import '../models/breakpoint.dart';
import '../models/wr_value.dart';
import '../themes/wr_theme.dart';

extension WRContextExtensions on BuildContext {
  /// Breakpoint actual, según el ancho de la pantalla.
  Breakpoint get breakpoint =>
      WRTheme.of(this).breakpoints.of(MediaQuery.sizeOf(this).width);

  /// Elige un valor según el breakpoint actual (cascada mobile-first).
  T? responsive<T>({T? xs, T? sm, T? md, T? lg, T? xl}) =>
      WRValue<T>(xs: xs, sm: sm, md: md, lg: lg, xl: xl).resolve(breakpoint);
}
