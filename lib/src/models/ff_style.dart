import 'package:flutter/material.dart';

import '../utils/context_extensions.dart';
import 'ff_color.dart';
import 'ff_decoration_style.dart';
import 'ff_layout_style.dart';
import 'ff_spacing.dart';
import 'ff_text_style.dart';
import 'ff_value.dart';

/// Optional composition of text, decoration, and layout styles.
///
/// Use [FFTextStyle], [FFDecorationStyle], or [FFLayoutStyle] directly when
/// only one concern is needed. This aggregate is a convenience for combining
/// them on a widget subtree.
@immutable
class FFStyle {
  const FFStyle({
    this.padding,
    this.margin,
    this.textStyle,
    this.color,
    this.fontWeight,
    this.fontSize,
    this.lineHeight,
    this.textAlign,
    this.backgroundColor,
    this.backgroundImage,
    this.shadow,
    this.borderRadius,
    this.borderWidth,
    this.borderColor,
    this.width,
    this.minWidth,
    this.maxWidth,
    this.height,
    this.maxHeight,
    this.clip,
    this.visible,
  });

  /// Builds a composed style from independent responsibility-specific styles.
  factory FFStyle.compose({
    FFTextStyle text = const FFTextStyle(),
    FFDecorationStyle decoration = const FFDecorationStyle(),
    FFLayoutStyle layout = const FFLayoutStyle(),
  }) => FFStyle(
    padding: layout.padding,
    margin: layout.margin,
    textStyle: text.textStyle,
    color: text.color,
    fontWeight: text.fontWeight,
    fontSize: text.fontSize,
    lineHeight: text.lineHeight,
    textAlign: text.textAlign,
    backgroundColor: decoration.backgroundColor,
    backgroundImage: decoration.backgroundImage,
    shadow: decoration.shadow,
    borderRadius: decoration.borderRadius,
    borderWidth: decoration.borderWidth,
    borderColor: decoration.borderColor,
    width: layout.width,
    minWidth: layout.minWidth,
    maxWidth: layout.maxWidth,
    height: layout.height,
    maxHeight: layout.maxHeight,
    clip: layout.clip,
    visible: layout.visible,
  );

  final FFSpacing? padding;
  final FFSpacing? margin;

  /// Base text style. Values merge from `xs` through the active breakpoint.
  final FFValue<TextStyle>? textStyle;

  /// Text color that adapts to the current theme brightness.
  final FFColor? color;
  final FFValue<FontWeight>? fontWeight;
  final FFValue<double>? fontSize;

  /// Line height as a multiple of the font size.
  final FFValue<double>? lineHeight;
  final FFValue<TextAlign>? textAlign;

  /// Background color per breakpoint, with optional light/dark variants.
  final FFValue<FFColor>? backgroundColor;

  /// Image painted over [backgroundColor].
  final FFValue<DecorationImage>? backgroundImage;

  final FFValue<List<BoxShadow>>? shadow;
  final FFValue<BorderRadiusGeometry>? borderRadius;
  final FFValue<double>? borderWidth;

  /// Defaults to the theme's `outlineVariant`.
  final FFColor? borderColor;

  final FFValue<double>? width;
  final FFValue<double>? minWidth;
  final FFValue<double>? maxWidth;
  final FFValue<double>? height;
  final FFValue<double>? maxHeight;

  /// `false` hides the widget at that breakpoint.
  final FFValue<bool>? visible;

  /// Clips content to the resolved bounds.
  final FFValue<bool>? clip;

  FFTextStyle get text => FFTextStyle(
    textStyle: textStyle,
    color: color,
    fontWeight: fontWeight,
    fontSize: fontSize,
    lineHeight: lineHeight,
    textAlign: textAlign,
  );

  FFDecorationStyle get decoration => FFDecorationStyle(
    backgroundColor: backgroundColor,
    backgroundImage: backgroundImage,
    shadow: shadow,
    borderRadius: borderRadius,
    borderWidth: borderWidth,
    borderColor: borderColor,
  );

  FFLayoutStyle get layout => FFLayoutStyle(
    padding: padding,
    margin: margin,
    width: width,
    minWidth: minWidth,
    maxWidth: maxWidth,
    height: height,
    maxHeight: maxHeight,
    visible: visible,
    clip: clip,
  );

  /// Combines styles; values from [other] take precedence where defined.
  FFStyle merge(FFStyle? other) {
    if (other == null) return this;
    return FFStyle.compose(
      text: text.merge(other.text),
      decoration: decoration.merge(other.decoration),
      layout: layout.merge(other.layout),
    );
  }

  /// Flutter [TextStyle] with the values defined for the current context.
  TextStyle toTextStyle(BuildContext context) => text.resolve(context);

  /// All values resolved for the current breakpoint and theme mode.
  FFResolvedStyle resolve(BuildContext context) {
    final resolvedText = text.resolve(context);
    final resolvedDecoration = decoration.resolve(context);
    final resolvedLayout = layout.resolve(context);
    return FFResolvedStyle(
      padding: resolvedLayout.padding,
      margin: resolvedLayout.margin,
      textStyle: resolvedText,
      textAlign: textAlign?.resolve(context.breakpoint),
      backgroundColor: resolvedDecoration.backgroundColor,
      backgroundImage: resolvedDecoration.backgroundImage,
      shadow: resolvedDecoration.shadow,
      borderRadius: resolvedDecoration.borderRadius,
      borderWidth: resolvedDecoration.borderWidth,
      borderColor: resolvedDecoration.borderColor,
      width: resolvedLayout.width,
      minWidth: resolvedLayout.minWidth,
      maxWidth: resolvedLayout.maxWidth,
      height: resolvedLayout.height,
      maxHeight: resolvedLayout.maxHeight,
      visible: resolvedLayout.visible,
      clip: resolvedLayout.clip,
    );
  }
}

/// An [FFStyle] resolved to standard Flutter types.
@immutable
class FFResolvedStyle {
  const FFResolvedStyle({
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.textStyle = const TextStyle(),
    this.textAlign,
    this.backgroundColor,
    this.backgroundImage,
    this.shadow = const [],
    this.borderRadius = BorderRadius.zero,
    this.borderWidth = 0,
    this.borderColor = const Color(0x00000000),
    this.width,
    this.minWidth,
    this.maxWidth,
    this.height,
    this.maxHeight,
    this.visible = true,
    this.clip = false,
  });

  final EdgeInsets padding;
  final EdgeInsets margin;
  final TextStyle textStyle;
  final TextAlign? textAlign;
  final Color? backgroundColor;
  final DecorationImage? backgroundImage;
  final List<BoxShadow> shadow;
  final BorderRadius borderRadius;
  final double borderWidth;
  final Color borderColor;
  final double? width;
  final double? minWidth;
  final double? maxWidth;
  final double? height;
  final double? maxHeight;
  final bool visible;
  final bool clip;
}
