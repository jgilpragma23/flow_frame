import 'package:flutter/widgets.dart';

import '../models/ff_style.dart';
import '../models/ff_value.dart';
import '../utils/ff_style_builder.dart';

/// A responsive item with styling, like a `div` with classes.
///
/// Inside an `FFFlex`, [col] and [fill] define its width, and [order] changes
/// its position. Outside an `FFFlex`, these three properties are ignored and
/// only [style] is applied.
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
    this.style,
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
  final FFStyle? style;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final s = style?.resolve(context);
    if (s == null || (s.width == null && s.maxWidth == null)) {
      return buildFFStyle(context, style, child);
    }
    // The column has a fixed width in `FFFlex`. Release it so the style can
    // constrain the box at the start of its column, while the content fills
    // that width like a block.
    return Align(
      alignment: AlignmentDirectional.topStart,
      heightFactor: 1,
      child: buildFFStyle(
        context,
        style,
        SizedBox(width: double.infinity, child: child),
      ),
    );
  }
}
