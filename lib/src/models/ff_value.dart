import 'package:flutter/widgets.dart';

import 'breakpoint.dart';

/// A value that changes per breakpoint, with mobile-first cascading.
///
/// Each value applies from its breakpoint upward until another one replaces
/// it: `FFValue(xs: 8, md: 16)` gives 8 on `xs`/`sm` and 16 on `md`/`lg`/`xl`.
@immutable
class FFValue<T> {
  const FFValue({this.xs, this.sm, this.md, this.lg, this.xl});

  /// The same value at every breakpoint.
  const FFValue.all(T value)
    : xs = value,
      sm = null,
      md = null,
      lg = null,
      xl = null;

  final T? xs;
  final T? sm;
  final T? md;
  final T? lg;
  final T? xl;

  /// Value defined exactly at [breakpoint], without cascading.
  T? at(BreakpointEnum breakpoint) => switch (breakpoint) {
    BreakpointEnum.xs => xs,
    BreakpointEnum.sm => sm,
    BreakpointEnum.md => md,
    BreakpointEnum.lg => lg,
    BreakpointEnum.xl => xl,
  };

  /// Value for [breakpoint], or `null` if none is defined there or at a
  /// smaller breakpoint.
  T? resolve(BreakpointEnum breakpoint) {
    for (var i = breakpoint.index; i >= 0; i--) {
      final value = at(BreakpointEnum.values[i]);
      if (value != null) return value;
    }
    return null;
  }

  /// Merges breakpoint by breakpoint; [other] takes precedence where it
  /// defines a value.
  FFValue<T> merge(FFValue<T>? other) {
    if (other == null) return this;
    return FFValue(
      xs: other.xs ?? xs,
      sm: other.sm ?? sm,
      md: other.md ?? md,
      lg: other.lg ?? lg,
      xl: other.xl ?? xl,
    );
  }

  /// Like [merge], but accepts either value being `null`.
  static FFValue<T>? combine<T>(FFValue<T>? a, FFValue<T>? b) =>
      a == null ? b : a.merge(b);

  @override
  bool operator ==(Object other) =>
      other is FFValue<T> &&
      other.xs == xs &&
      other.sm == sm &&
      other.md == md &&
      other.lg == lg &&
      other.xl == xl;

  @override
  int get hashCode => Object.hash(xs, sm, md, lg, xl);
}

extension FFTextStyleValue on FFValue<TextStyle> {
  /// Merges styles from `xs` through [breakpoint]; the value from the largest
  /// breakpoint takes precedence for each property.
  TextStyle? resolveMerged(BreakpointEnum breakpoint) {
    TextStyle? result;
    for (var i = 0; i <= breakpoint.index; i++) {
      final style = at(BreakpointEnum.values[i]);
      if (style != null) result = result?.merge(style) ?? style;
    }
    return result;
  }

  /// Merges breakpoint by breakpoint; styles defined at the same breakpoint
  /// are merged, with [other] taking precedence where it defines a value.
  FFValue<TextStyle> mergeStyles(FFValue<TextStyle>? other) {
    if (other == null) return this;
    TextStyle? m(TextStyle? a, TextStyle? b) => a?.merge(b) ?? b;
    return FFValue(
      xs: m(xs, other.xs),
      sm: m(sm, other.sm),
      md: m(md, other.md),
      lg: m(lg, other.lg),
      xl: m(xl, other.xl),
    );
  }
}
