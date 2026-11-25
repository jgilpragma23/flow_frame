import 'package:flutter/widgets.dart';

import '../utils/context_extensions.dart';
import 'ff_color.dart';
import 'ff_value.dart';

/// Responsive text properties, independent of box layout and decoration.
@immutable
class FFTextStyle {
  const FFTextStyle({
    this.textStyle,
    this.color,
    this.fontWeight,
    this.fontSize,
    this.lineHeight,
    this.textAlign,
  });

  /// Base text style. Values merge from `xs` through the active breakpoint.
  final FFValue<TextStyle>? textStyle;

  /// Text color that adapts to the current theme brightness.
  final FFColor? color;
  final FFValue<FontWeight>? fontWeight;
  final FFValue<double>? fontSize;

  /// Line height as a multiple of the font size.
  final FFValue<double>? lineHeight;
  final FFValue<TextAlign>? textAlign;

  /// Resolves this text style for the current breakpoint and theme.
  TextStyle resolve(BuildContext context) {
    final breakpoint = context.breakpoint;
    final base = textStyle?.resolveMerged(breakpoint) ?? const TextStyle();
    return base.copyWith(
      color: color?.resolve(context),
      fontWeight: fontWeight?.resolve(breakpoint),
      fontSize: fontSize?.resolve(breakpoint),
      height: lineHeight?.resolve(breakpoint),
    );
  }

  FFTextStyle merge(FFTextStyle? other) {
    if (other == null) return this;
    return FFTextStyle(
      textStyle: textStyle?.mergeStyles(other.textStyle) ?? other.textStyle,
      color: other.color ?? color,
      fontWeight: FFValue.combine(fontWeight, other.fontWeight),
      fontSize: FFValue.combine(fontSize, other.fontSize),
      lineHeight: FFValue.combine(lineHeight, other.lineHeight),
      textAlign: FFValue.combine(textAlign, other.textAlign),
    );
  }
}
