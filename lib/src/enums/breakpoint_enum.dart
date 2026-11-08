import '../models/breakpoint.dart';

/// Screen-width ranges, ordered from smallest to largest.
enum BreakpointEnum {
  xs,
  sm,
  md,
  lg,
  xl;

  /// The breakpoint for [width], according to [FFBreakpoints.current].
  static BreakpointEnum fromWidth(double width) =>
      FFBreakpoints.current.of(width);

  bool operator >=(BreakpointEnum other) => index >= other.index;
  bool operator >(BreakpointEnum other) => index > other.index;
  bool operator <=(BreakpointEnum other) => index <= other.index;
  bool operator <(BreakpointEnum other) => index < other.index;
}
