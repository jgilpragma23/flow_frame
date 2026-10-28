import 'package:flutter/foundation.dart';

/// Rangos de ancho de pantalla, ordenados de menor a mayor.
enum Breakpoint {
  xs,
  sm,
  md,
  lg,
  xl;

  /// El breakpoint que corresponde a [width], según [WRBreakpoints.current].
  static Breakpoint fromWidth(double width) => WRBreakpoints.current.of(width);

  bool operator >=(Breakpoint other) => index >= other.index;
  bool operator >(Breakpoint other) => index > other.index;
  bool operator <=(Breakpoint other) => index <= other.index;
  bool operator <(Breakpoint other) => index < other.index;
}

/// Ancho mínimo (en píxeles lógicos) desde el que empieza cada breakpoint.
///
/// `xs` siempre empieza en 0. Para cambiar las medidas, asigna
/// [current] una vez antes de `runApp`:
///
/// ```dart
/// void main() {
///   WRBreakpoints.current = const WRBreakpoints(md: 900);
///   runApp(const MyApp());
/// }
/// ```
@immutable
class WRBreakpoints {
  const WRBreakpoints({
    this.sm = 600,
    this.md = 840,
    this.lg = 1200,
    this.xl = 1600,
  }) : assert(0 < sm && sm < md && md < lg && lg < xl);

  /// Medidas que usa la librería. Por defecto 600 / 840 / 1200 / 1600.
  static WRBreakpoints current = const WRBreakpoints();

  final double sm;
  final double md;
  final double lg;
  final double xl;

  /// Devuelve el breakpoint que corresponde a [width].
  Breakpoint of(double width) {
    if (width >= xl) return Breakpoint.xl;
    if (width >= lg) return Breakpoint.lg;
    if (width >= md) return Breakpoint.md;
    if (width >= sm) return Breakpoint.sm;
    return Breakpoint.xs;
  }

  @override
  bool operator ==(Object other) =>
      other is WRBreakpoints &&
      other.sm == sm &&
      other.md == md &&
      other.lg == lg &&
      other.xl == xl;

  @override
  int get hashCode => Object.hash(sm, md, lg, xl);
}
