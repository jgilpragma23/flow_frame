import 'package:flutter/foundation.dart';

import '../enums/breakpoint_enum.dart';

export '../enums/breakpoint_enum.dart';

/// Minimum width (in logical pixels) at which each breakpoint starts.
///
/// `xs` always starts at 0. To customize the thresholds, assign [current]
/// once before `runApp`:
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

  /// Thresholds used by all responsive widgets in the package.
  ///
  /// This configuration is global to the process. Assign it before `runApp`
  /// to keep breakpoints consistent throughout the application.
  static FFBreakpoints current = const FFBreakpoints();

  final double sm;
  final double md;
  final double lg;
  final double xl;

  /// Returns the breakpoint for [width].
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
