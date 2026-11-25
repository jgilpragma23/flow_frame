/// Screen-width ranges, ordered from smallest to largest.
enum BreakpointEnum {
  xs,
  sm,
  md,
  lg,
  xl;

  bool operator >=(BreakpointEnum other) => index >= other.index;
  bool operator >(BreakpointEnum other) => index > other.index;
  bool operator <=(BreakpointEnum other) => index <= other.index;
  bool operator <(BreakpointEnum other) => index < other.index;
}
