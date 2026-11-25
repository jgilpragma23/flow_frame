import 'package:flutter/widgets.dart';

/// Main container: uses the available width up to [maxSize], centers
/// horizontally.
class FFContainer extends StatelessWidget {
  const FFContainer({super.key, this.maxSize, required this.child})
    : assert(maxSize == null || maxSize > 0);

  /// Maximum width. If `null`, the container uses the full available width.
  final double? maxSize;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxSize ?? double.infinity),
        child: SizedBox(width: double.infinity, child: child),
      ),
    );
  }
}
