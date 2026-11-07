import 'package:flutter/foundation.dart';

import '../enums/breakpoint_enum.dart';

export '../enums/breakpoint_enum.dart';

/// Ancho mínimo (en píxeles lógicos) desde el que empieza cada breakpoint.
///
/// `xs` siempre empieza en 0. Para cambiar las medidas, asigna
/// [current] una vez antes de `runApp`:
///
/// ```dart
/// void main() {
///   FFBreakpoints.current = const FFBreakpoints(md: 900);
///   runApp(const MyApp());
/// }
/// ```
@immutable
class FFBreakpoints {
  const FFBreakpoints({
    this.sm = 600,
    this.md = 840,
    this.lg = 1200,
    this.xl = 1600,
  }) : assert(0 < sm && sm < md && md < lg && lg < xl);

  /// Medidas que usa la librería. Por defecto 600 / 840 / 1200 / 1600.
  static FFBreakpoints current = const FFBreakpoints();

  final double sm;
  final double md;
  final double lg;
  final double xl;

  /// Devuelve el breakpoint que corresponde a [width].
  BreakpointEnum of(double width) {
    if (width >= xl) return BreakpointEnum.xl;
    if (width >= lg) return BreakpointEnum.lg;
    if (width >= md) return BreakpointEnum.md;
    if (width >= sm) return BreakpointEnum.sm;
    return BreakpointEnum.xs;
  }

  @override
  bool operator ==(Object other) =>
      other is FFBreakpoints &&
      other.sm == sm &&
      other.md == md &&
      other.lg == lg &&
      other.xl == xl;

  @override
  int get hashCode => Object.hash(sm, md, lg, xl);
}
