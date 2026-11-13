import 'package:flutter/widgets.dart';

import '../enums/breakpoint_enum.dart';

export '../enums/breakpoint_enum.dart';

/// Minimum width (in logical pixels) at which each breakpoint starts.
///
/// `xs` always starts at 0. To customize the thresholds for an app or a
/// subtree, wrap it in [FFBreakpointScope]:
///
/// ```dart
/// FFBreakpointScope(
///   breakpoints: const FFBreakpoints(md: 900),
///   child: const MyApp(),
/// )
/// ```
@immutable
class FFBreakpoints {
  const FFBreakpoints({
    this.sm = 600,
    this.md = 840,
    this.lg = 1200,
    this.xl = 1600,
  }) : assert(0 < sm && sm < md && md < lg && lg < xl);

  /// Default responsive thresholds.
  static const defaults = FFBreakpoints();

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

/// Provides responsive thresholds to descendants.
///
/// Nested scopes can customize one part of an app without changing the
/// breakpoints used elsewhere. Descendants outside a scope use
/// [FFBreakpoints.defaults].
class FFBreakpointScope extends InheritedWidget {
  const FFBreakpointScope({
    super.key,
    this.breakpoints = FFBreakpoints.defaults,
    required super.child,
  });

  final FFBreakpoints breakpoints;

  /// Returns the nearest thresholds, or [FFBreakpoints.defaults] if absent.
  static FFBreakpoints of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<FFBreakpointScope>()
          ?.breakpoints ??
      FFBreakpoints.defaults;

  @override
  bool updateShouldNotify(FFBreakpointScope oldWidget) =>
      breakpoints != oldWidget.breakpoints;
}
