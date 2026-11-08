import 'package:flutter/widgets.dart';

import 'breakpoint.dart';
import 'ff_value.dart';

/// Spacing (padding or margin) that changes per breakpoint.
///
/// For each side, the value from the closest breakpoint takes precedence. If
/// multiple values are defined at that breakpoint, the most specific one
/// wins: a side (`top`) over an axis (`vertical`), and an axis over `all`.
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

  /// Spacing for [breakpoint]; sides without a value default to 0.
  EdgeInsets resolve(BreakpointEnum breakpoint) => EdgeInsets.fromLTRB(
    _side(breakpoint, left, horizontal),
    _side(breakpoint, top, vertical),
    _side(breakpoint, right, horizontal),
    _side(breakpoint, bottom, vertical),
  );

  double _side(
    BreakpointEnum breakpoint,
    FFValue<double>? side,
    FFValue<double>? axis,
  ) {
    for (var i = breakpoint.index; i >= 0; i--) {
      final b = BreakpointEnum.values[i];
      final value = side?.at(b) ?? axis?.at(b) ?? all?.at(b);
      if (value != null) return value;
    }
    return 0;
  }

  /// Merges breakpoint by breakpoint; [other] takes precedence where it
  /// defines a value.
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
