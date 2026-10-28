import 'package:flutter/widgets.dart';

import 'breakpoint.dart';
import 'wr_value.dart';

/// Padding que cambia según el breakpoint.
///
/// Cada lado hace su propia cascada, así que en `WRPadding.symmetric` el
/// horizontal y el vertical pueden cambiar en breakpoints distintos.
@immutable
class WRPadding {
  const WRPadding.only({
    this.left = const WRValue(),
    this.top = const WRValue(),
    this.right = const WRValue(),
    this.bottom = const WRValue(),
  });

  /// El mismo padding en los cuatro lados.
  WRPadding.all({double? xs, double? sm, double? md, double? lg, double? xl})
    : this._uniform(WRValue(xs: xs, sm: sm, md: md, lg: lg, xl: xl));

  const WRPadding._uniform(WRValue<double> value)
    : left = value,
      top = value,
      right = value,
      bottom = value;

  const WRPadding.symmetric({
    WRValue<double> horizontal = const WRValue(),
    WRValue<double> vertical = const WRValue(),
  }) : left = horizontal,
       right = horizontal,
       top = vertical,
       bottom = vertical;

  final WRValue<double> left;
  final WRValue<double> top;
  final WRValue<double> right;
  final WRValue<double> bottom;

  /// Padding para [breakpoint]; los lados sin valor quedan en 0.
  EdgeInsets resolve(Breakpoint breakpoint) => EdgeInsets.fromLTRB(
    left.resolve(breakpoint) ?? 0,
    top.resolve(breakpoint) ?? 0,
    right.resolve(breakpoint) ?? 0,
    bottom.resolve(breakpoint) ?? 0,
  );

  @override
  bool operator ==(Object other) =>
      other is WRPadding &&
      other.left == left &&
      other.top == top &&
      other.right == right &&
      other.bottom == bottom;

  @override
  int get hashCode => Object.hash(left, top, right, bottom);
}
