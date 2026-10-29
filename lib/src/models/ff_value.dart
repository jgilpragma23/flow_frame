import 'package:flutter/widgets.dart';

import 'breakpoint.dart';

/// Un valor que cambia según el breakpoint, con cascada mobile-first.
///
/// Cada valor aplica desde su breakpoint hacia arriba hasta que otro lo
/// reemplace: `FFValue(xs: 8, md: 16)` da 8 en `xs`/`sm` y 16 en `md`/`lg`/`xl`.
@immutable
class FFValue<T> {
  const FFValue({this.xs, this.sm, this.md, this.lg, this.xl});

  /// El mismo valor en todos los breakpoints.
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

  /// Valor definido exactamente en [breakpoint], sin cascada.
  T? at(Breakpoint breakpoint) => switch (breakpoint) {
    Breakpoint.xs => xs,
    Breakpoint.sm => sm,
    Breakpoint.md => md,
    Breakpoint.lg => lg,
    Breakpoint.xl => xl,
  };

  /// Valor para [breakpoint], o `null` si no hay ninguno definido en él
  /// ni en los breakpoints menores.
  T? resolve(Breakpoint breakpoint) {
    for (var i = breakpoint.index; i >= 0; i--) {
      final value = at(Breakpoint.values[i]);
      if (value != null) return value;
    }
    return null;
  }

  /// Combina breakpoint por breakpoint; [other] gana donde define un valor.
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

  /// Como [merge], pero acepta que cualquiera de los dos sea `null`.
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

extension WRTextStyleValue on FFValue<TextStyle> {
  /// Combina los estilos desde `xs` hasta [breakpoint]; en cada propiedad
  /// gana el breakpoint mayor.
  TextStyle? resolveMerged(Breakpoint breakpoint) {
    TextStyle? result;
    for (var i = 0; i <= breakpoint.index; i++) {
      final style = at(Breakpoint.values[i]);
      if (style != null) result = result?.merge(style) ?? style;
    }
    return result;
  }

  /// Combina breakpoint por breakpoint; en el mismo breakpoint los estilos
  /// se mezclan y [other] gana en lo que define.
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
