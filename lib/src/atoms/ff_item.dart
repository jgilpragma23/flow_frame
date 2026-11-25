import 'package:flutter/widgets.dart';

import '../models/ff_value.dart';

/// A responsive grid item.
///
/// Inside an `FFFlex`, [col] and [fill] define its width, and [order] changes
/// its position. Outside an `FFFlex`, these properties are ignored.
///
/// If [col] and [fill] are both defined, the value from the breakpoint closest
/// to the current one takes precedence; if both are defined at the same
/// breakpoint, [col] takes precedence.
class FFItem extends StatelessWidget {
  const FFItem({
    super.key,
    this.col,
    this.fill,
    this.order,
    this.visible,
    required this.child,
  });

  /// How many of the 12 columns this item occupies in a horizontal `FFFlex`
  /// (like `col-md-6`). Items that do not fit wrap to the next row. Values
  /// range from 1 to 12. Without `col` or [fill], it occupies the full row
  /// (12). Ignored in a vertical `FFFlex`.
  final FFValue<int>? col;

  /// `true`: occupies the remaining space in its row (or column, for a
  /// vertical `FFFlex`); if multiple items use it, they split the space
  /// equally. `false`: uses its natural size, like `col-auto`.
  final FFValue<bool>? fill;

  /// Position within the `FFFlex`; lower values come first. Defaults to 0.
  final FFValue<int>? order;

  /// Whether this item participates in the layout at each breakpoint.
  final FFValue<bool>? visible;

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}
