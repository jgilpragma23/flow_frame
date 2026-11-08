import 'package:flutter/widgets.dart';

import '../models/ff_style.dart';

/// Wraps [child] in the widgets that apply [style].
///
/// From inside out: text, padding, clipping, corners, border, background,
/// image and shadow, size, width and height constraints, and margin. Used
/// internally by package widgets.
Widget buildFFStyle(BuildContext context, FFStyle? style, Widget child) {
  if (style == null) return child;
  final s = style.resolve(context);
  if (!s.visible) return const SizedBox.shrink();

  var current = child;
  if (s.textStyle != const TextStyle() || s.textAlign != null) {
    current = DefaultTextStyle.merge(
      style: s.textStyle,
      textAlign: s.textAlign,
      child: current,
    );
  }
  if (s.padding != EdgeInsets.zero) {
    current = Padding(padding: s.padding, child: current);
  }
  // Like overflow: hidden. Content uses its natural height and anything that
  // does not fit is clipped at the padding edge.
  if (s.clip) {
    current = UnconstrainedBox(
      constrainedAxis: Axis.horizontal,
      alignment: AlignmentDirectional.topStart,
      clipBehavior: Clip.hardEdge,
      child: current,
    );
  }
  final rounded = s.borderRadius != BorderRadius.zero;
  // Corners clip inside the border, using the inner radius.
  if (rounded) {
    current = ClipRRect(
      borderRadius: _inner(s.borderRadius, s.borderWidth),
      child: current,
    );
  }
  // The border is inside the box, so add it to the padding.
  if (s.borderWidth > 0) {
    current = Padding(padding: EdgeInsets.all(s.borderWidth), child: current);
  }
  if (s.backgroundImage != null ||
      s.shadow.isNotEmpty ||
      rounded ||
      s.borderWidth > 0) {
    current = DecoratedBox(
      decoration: BoxDecoration(
        color: s.backgroundColor,
        image: s.backgroundImage,
        boxShadow: s.shadow,
        borderRadius: rounded ? s.borderRadius : null,
        border: s.borderWidth > 0
            ? Border.all(color: s.borderColor, width: s.borderWidth)
            : null,
      ),
      child: current,
    );
  } else if (s.backgroundColor != null) {
    current = ColoredBox(color: s.backgroundColor!, child: current);
  }
  if (s.width != null || s.height != null) {
    current = SizedBox(width: s.width, height: s.height, child: current);
  }
  if (s.minWidth != null || s.maxWidth != null || s.maxHeight != null) {
    current = ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: s.minWidth ?? 0,
        maxWidth: s.maxWidth ?? double.infinity,
        maxHeight: s.maxHeight ?? double.infinity,
      ),
      child: current,
    );
  }
  if (s.margin != EdgeInsets.zero) {
    current = Padding(padding: s.margin, child: current);
  }
  return current;
}

/// [radius] minus the border width at each corner, clamped to 0.
BorderRadius _inner(BorderRadius radius, double width) {
  Radius shrink(Radius r) => Radius.elliptical(
    (r.x - width).clamp(0, double.infinity),
    (r.y - width).clamp(0, double.infinity),
  );
  return BorderRadius.only(
    topLeft: shrink(radius.topLeft),
    topRight: shrink(radius.topRight),
    bottomLeft: shrink(radius.bottomLeft),
    bottomRight: shrink(radius.bottomRight),
  );
}
