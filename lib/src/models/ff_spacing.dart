import 'package:flutter/widgets.dart';

import 'breakpoint.dart';
import 'ff_value.dart';

/// Espaciado (padding o margin) que cambia según el breakpoint.
///
/// Para cada lado gana el breakpoint más cercano al actual. Si en ese
/// breakpoint hay varios valores, gana el más específico: el lado (`top`)
/// sobre el eje (`vertical`), y el eje sobre `all`.
@immutable
class FFSpacing {
  const FFSpacing({
    this.all,
    this.horizontal,
    this.vertical,
    this.top,
    this.bottom,
    this.left,
    this.right,
  });

  final FFValue<double>? all;
  final FFValue<double>? horizontal;
  final FFValue<double>? vertical;
  final FFValue<double>? top;
  final FFValue<double>? bottom;
  final FFValue<double>? left;
  final FFValue<double>? right;

  /// Espaciado para [breakpoint]; los lados sin valor quedan en 0.
  EdgeInsets resolve(Breakpoint breakpoint) => EdgeInsets.fromLTRB(
    _side(breakpoint, left, horizontal),
    _side(breakpoint, top, vertical),
    _side(breakpoint, right, horizontal),
    _side(breakpoint, bottom, vertical),
  );

  double _side(
    Breakpoint breakpoint,
    FFValue<double>? side,
    FFValue<double>? axis,
  ) {
    for (var i = breakpoint.index; i >= 0; i--) {
      final b = Breakpoint.values[i];
      final value = side?.at(b) ?? axis?.at(b) ?? all?.at(b);
      if (value != null) return value;
    }
    return 0;
  }

  /// Combina breakpoint por breakpoint; [other] gana donde define un valor.
  FFSpacing merge(FFSpacing? other) {
    if (other == null) return this;
    return FFSpacing(
      all: FFValue.combine(all, other.all),
      horizontal: FFValue.combine(horizontal, other.horizontal),
      vertical: FFValue.combine(vertical, other.vertical),
      top: FFValue.combine(top, other.top),
      bottom: FFValue.combine(bottom, other.bottom),
      left: FFValue.combine(left, other.left),
      right: FFValue.combine(right, other.right),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is FFSpacing &&
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
