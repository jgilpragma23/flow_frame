import 'package:flutter/material.dart';

import '../models/breakpoint.dart';
import '../models/wr_palette.dart';
import '../models/wr_value.dart';
import '../utils/context_extensions.dart';

/// Configuración de la librería.
@immutable
class WRThemeData {
  const WRThemeData({
    this.breakpoints = const WRBreakpoints(),
    this.colors = const WRColorScheme(),
    this.textStyle,
    this.themeMode,
  });

  final WRBreakpoints breakpoints;
  final WRColorScheme colors;

  /// Estilo de texto base de toda la app.
  final WRValue<TextStyle>? textStyle;

  /// Fuerza el modo claro u oscuro. Si es `null`, se sigue al `Theme` de
  /// Material.
  final ThemeMode? themeMode;

  @override
  bool operator ==(Object other) =>
      other is WRThemeData &&
      other.breakpoints == breakpoints &&
      other.colors == colors &&
      other.textStyle == textStyle &&
      other.themeMode == themeMode;

  @override
  int get hashCode => Object.hash(breakpoints, colors, textStyle, themeMode);
}

/// Aplica un [WRThemeData] a todo lo que está debajo, y pone el estilo de
/// texto base (con el color `text` de la paleta) a todos los textos.
///
/// Es opcional: sin un `WRTheme` arriba se usan los valores por defecto y
/// no se aplica estilo de texto base.
class WRTheme extends StatelessWidget {
  const WRTheme({super.key, required this.data, required this.child});

  final WRThemeData data;
  final Widget child;

  static WRThemeData of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_WRThemeScope>()?.data ??
      const WRThemeData();

  @override
  Widget build(BuildContext context) {
    return _WRThemeScope(
      data: data,
      child: Builder(
        builder: (context) {
          final base =
              data.textStyle?.resolveMerged(context.breakpoint) ??
              const TextStyle();
          return DefaultTextStyle.merge(
            style: base.copyWith(color: base.color ?? context.wrColors.text),
            child: child,
          );
        },
      ),
    );
  }
}

class _WRThemeScope extends InheritedWidget {
  const _WRThemeScope({required this.data, required super.child});

  final WRThemeData data;

  @override
  bool updateShouldNotify(_WRThemeScope oldWidget) => data != oldWidget.data;
}
