import 'package:flutter/widgets.dart';

import '../models/ff_decoration_style.dart';
import '../models/ff_layout_style.dart';
import '../models/ff_style.dart';
import '../models/ff_text_style.dart';
import '../utils/ff_style_builder.dart';

/// Applies an [FFStyle] to any widget subtree.
class FFStyled extends StatelessWidget {
  FFStyled({
    super.key,
    FFStyle? style,
    FFTextStyle? text,
    FFDecorationStyle? decoration,
    FFLayoutStyle? layout,
    required this.child,
  }) : style = _compose(style, text, decoration, layout);

  final FFStyle? style;
  final Widget child;

  @override
  Widget build(BuildContext context) => buildFFStyle(context, style, child);

  static FFStyle? _compose(
    FFStyle? style,
    FFTextStyle? text,
    FFDecorationStyle? decoration,
    FFLayoutStyle? layout,
  ) {
    if (text == null && decoration == null && layout == null) return style;
    final parts = FFStyle.compose(
      text: text ?? const FFTextStyle(),
      decoration: decoration ?? const FFDecorationStyle(),
      layout: layout ?? const FFLayoutStyle(),
    );
    return style?.merge(parts) ?? parts;
  }
}
