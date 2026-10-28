import 'package:flutter/widgets.dart';

import '../models/breakpoint.dart';

/// Configuración de la librería.
@immutable
class WRThemeData {
  const WRThemeData({this.breakpoints = const WRBreakpoints()});

  final WRBreakpoints breakpoints;

  @override
  bool operator ==(Object other) =>
      other is WRThemeData && other.breakpoints == breakpoints;

  @override
  int get hashCode => breakpoints.hashCode;
}

/// Aplica un [WRThemeData] a todo lo que está debajo.
///
/// Es opcional: sin un `WRTheme` arriba se usan los valores por defecto.
class WRTheme extends InheritedWidget {
  const WRTheme({super.key, required this.data, required super.child});

  final WRThemeData data;

  static WRThemeData of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<WRTheme>()?.data ??
      const WRThemeData();

  @override
  bool updateShouldNotify(WRTheme oldWidget) => data != oldWidget.data;
}
