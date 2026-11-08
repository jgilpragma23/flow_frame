import 'package:flutter/widgets.dart';

import '../models/ff_style.dart';
import '../utils/ff_style_builder.dart';

/// Main container: uses the available width up to [maxSize], centers
/// horizontally, and applies [style] within that width.
///
/// Nested `Text` widgets inherit the text style from [style].
class FFContainer extends StatelessWidget {
  const FFContainer({super.key, this.maxSize, this.style, required this.child})
    : assert(maxSize == null || maxSize > 0);

  /// Maximum width. If `null`, the container uses the full available width.
  final double? maxSize;
  final FFStyle? style;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxSize ?? double.infinity),
        // Apply the style outside the full-width child so maxWidth, minWidth,
        // and width constrain the centered box.
        child: buildFFStyle(
          context,
          style,
          SizedBox(width: double.infinity, child: child),
        ),
      ),
    );
  }
}
