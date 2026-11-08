import 'package:flutter/widgets.dart';

/// Direction for an `FFFlex`, similar to Bootstrap's `flex-row`,
/// `flex-row-reverse`, `flex-column`, and `flex-column-reverse`.
enum FFDirectionEnum {
  /// Arranges items in 12-column rows; items that do not fit wrap to the next.
  horizontal,

  /// Like [horizontal], but with children in reverse order: the last item
  /// moves to the left in a row or to the top when stacked.
  horizontalReverse,

  /// Stacks items from top to bottom.
  vertical,

  /// Stacks items from bottom to top.
  verticalReverse;

  Axis get axis => switch (this) {
    horizontal || horizontalReverse => Axis.horizontal,
    vertical || verticalReverse => Axis.vertical,
  };

  bool get isReverse => this == horizontalReverse || this == verticalReverse;
}
