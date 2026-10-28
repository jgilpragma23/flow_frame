import 'package:flutter/foundation.dart';

import 'breakpoint.dart';

/// Un valor que cambia según el breakpoint, con cascada mobile-first.
///
/// Cada valor aplica desde su breakpoint hacia arriba hasta que otro lo
/// reemplace: `WRValue(xs: 8, md: 16)` da 8 en `xs`/`sm` y 16 en `md`/`lg`/`xl`.
@immutable
class WRValue<T> {
  const WRValue({this.xs, this.sm, this.md, this.lg, this.xl});

  /// El mismo valor en todos los breakpoints.
  const WRValue.all(T value)
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

  /// Valor para [breakpoint], o `null` si no hay ninguno definido en él
  /// ni en los breakpoints menores.
  T? resolve(Breakpoint breakpoint) {
    final values = [xs, sm, md, lg, xl];
    for (var i = breakpoint.index; i >= 0; i--) {
      final value = values[i];
      if (value != null) return value;
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      other is WRValue<T> &&
      other.xs == xs &&
      other.sm == sm &&
      other.md == md &&
      other.lg == lg &&
      other.xl == xl;

  @override
  int get hashCode => Object.hash(xs, sm, md, lg, xl);
}
