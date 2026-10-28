import 'package:flutter/widgets.dart';

import 'breakpoint.dart';
import 'wr_value.dart';

/// Espaciado (padding o margin) que cambia según el breakpoint.
///
/// Para cada lado gana el breakpoint más cercano al actual. Si en ese
/// breakpoint hay varios valores, gana el más específico: el lado (`top`)
/// sobre el eje (`vertical`), y el eje sobre `all`.
@immutable
class WRSpacing {
  const WRSpacing({
    this.all,
    this.horizontal,
    this.vertical,
    this.top,
    this.bottom,
    this.left,
    this.right,
  });

  final WRValue<double>? all;
  final WRValue<double>? horizontal;
  final WRValue<double>? vertical;
  final WRValue<double>? top;
  final WRValue<double>? bottom;
  final WRValue<double>? left;
  final WRValue<double>? right;

  /// Espaciado para [breakpoint]; los lados sin valor quedan en 0.
  EdgeInsets resolve(Breakpoint breakpoint) => EdgeInsets.fromLTRB(
    _side(breakpoint, left, horizontal),
    _side(breakpoint, top, vertical),
    _side(breakpoint, right, horizontal),
    _side(breakpoint, bottom, vertical),
  );

  double _side(
    Breakpoint breakpoint,
    WRValue<double>? side,
    WRValue<double>? axis,
  ) {
    for (var i = breakpoint.index; i >= 0; i--) {
      final b = Breakpoint.values[i];
      final value = side?.at(b) ?? axis?.at(b) ?? all?.at(b);
      if (value != null) return value;
    }
    return 0;
  }

  /// Combina breakpoint por breakpoint; [other] gana donde define un valor.
  WRSpacing merge(WRSpacing? other) {
    if (other == null) return this;
    return WRSpacing(
      all: WRValue.combine(all, other.all),
      horizontal: WRValue.combine(horizontal, other.horizontal),
      vertical: WRValue.combine(vertical, other.vertical),
      top: WRValue.combine(top, other.top),
      bottom: WRValue.combine(bottom, other.bottom),
      left: WRValue.combine(left, other.left),
      right: WRValue.combine(right, other.right),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is WRSpacing &&
      other.all == all &&
      other.horizontal == horizontal &&
      other.vertical == vertical &&
      other.top == top &&
      other.bottom == bottom &&
      other.left == left &&
      other.right == right;

  @override
  int get hashCode =>
      Object.hash(all, horizontal, vertical, top, bottom, left, right);
}
