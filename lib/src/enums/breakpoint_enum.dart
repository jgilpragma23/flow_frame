import '../models/breakpoint.dart';

/// Rangos de ancho de pantalla, ordenados de menor a mayor.
enum BreakpointEnum {
  xs,
  sm,
  md,
  lg,
  xl;

  /// El breakpoint que corresponde a [width], según [FFBreakpoints.current].
  static BreakpointEnum fromWidth(double width) =>
      FFBreakpoints.current.of(width);

  bool operator >=(BreakpointEnum other) => index >= other.index;
  bool operator >(BreakpointEnum other) => index > other.index;
  bool operator <=(BreakpointEnum other) => index <= other.index;
  bool operator <(BreakpointEnum other) => index < other.index;
}
