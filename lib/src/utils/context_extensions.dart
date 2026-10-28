import 'package:flutter/material.dart';

import '../models/breakpoint.dart';
import '../models/wr_palette.dart';
import '../models/wr_value.dart';
import '../themes/wr_theme.dart';

extension WRContextExtensions on BuildContext {
  /// Breakpoint actual, según el ancho de la pantalla.
  Breakpoint get breakpoint =>
      WRTheme.of(this).breakpoints.of(MediaQuery.sizeOf(this).width);

  /// Elige un valor según el breakpoint actual (cascada mobile-first).
  T? responsive<T>({T? xs, T? sm, T? md, T? lg, T? xl}) =>
      WRValue<T>(xs: xs, sm: sm, md: md, lg: lg, xl: xl).resolve(breakpoint);

  /// Modo actual. Usa el `themeMode` de [WRThemeData] si está definido;
  /// si no, sigue al `Theme` de Material (el de `MaterialApp`).
  Brightness get wrBrightness => switch (WRTheme.of(this).themeMode) {
    ThemeMode.light => Brightness.light,
    ThemeMode.dark => Brightness.dark,
    ThemeMode.system => MediaQuery.platformBrightnessOf(this),
    null => Theme.of(this).brightness,
  };

  /// Paleta del modo actual.
  WRPalette get wrColors => WRTheme.of(this).colors.of(wrBrightness);
}
