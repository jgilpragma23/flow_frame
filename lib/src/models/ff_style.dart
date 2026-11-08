import 'package:flutter/material.dart';

import '../utils/context_extensions.dart';
import 'ff_color.dart';
import 'ff_spacing.dart';
import 'ff_value.dart';

/// Reusable responsive style, similar to a CSS class.
///
/// For text, [textStyle] is the base, with [color], [fontWeight], [fontSize],
/// and [lineHeight] applied on top.
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

  final FFSpacing? padding;
  final FFSpacing? margin;

  /// Base text style. Styles are merged from `xs` at each breakpoint, so
  /// values defined at `xs` are retained at `md`.
  final FFValue<TextStyle>? textStyle;

  /// Text color; adapts to light and dark modes.
  final FFColor? color;
  final FFValue<FontWeight>? fontWeight;
  final FFValue<double>? fontSize;

  /// Line height as a multiple of the font size.
  final FFValue<double>? lineHeight;
  final FFValue<TextAlign>? textAlign;

  /// Background color per breakpoint; each `FFColor` adapts to light and dark
  /// modes.
  final FFValue<FFColor>? backgroundColor;

  /// Background image per breakpoint, painted over [backgroundColor]. Use
  /// `DecorationImage` to configure `fit`, `alignment`, opacity, and more.
  final FFValue<DecorationImage>? backgroundImage;

  /// Shadow per breakpoint. `FFShadow` provides lists of shadows;
  /// `FFShadow.none` removes the shadow at a larger breakpoint.
  final FFValue<List<BoxShadow>>? shadow;

  /// Corners per breakpoint, using Flutter's `BorderRadius`: all equal
  /// (`BorderRadius.all(Radius.circular(12))`), top only
  /// (`BorderRadius.vertical(top: ...)`), or independently configured
  /// (`BorderRadius.only(...)` or `BorderRadiusDirectional` for start and
  /// end). Rounds the background, shadow, and border, and clips content to
  /// that shape.
  final FFValue<BorderRadiusGeometry>? borderRadius;

  /// Border width. Added to the padding so the content does not overlap it.
  final FFValue<double>? borderWidth;

  /// Border color. Defaults to the theme's `outlineVariant`.
  final FFColor? borderColor;

  final FFValue<double>? width;
  final FFValue<double>? minWidth;
  final FFValue<double>? maxWidth;
  final FFValue<double>? height;

  /// Maximum height. Content that does not fit overflows, so long content
  /// should use a scrollable child (for example, a `ListView`).
  final FFValue<double>? maxHeight;

  /// `false` hides the widget at that breakpoint (equivalent to `d-none`).
  final FFValue<bool>? visible;

  /// `true` clips overflowing content, like `overflow: hidden`: content uses
  /// its natural height, and anything beyond [height] or [maxHeight] is
  /// clipped at the padding edge, following [borderRadius]. Not suitable for
  /// scrollable children (`ListView`), which need a fixed height.
  final FFValue<bool>? clip;

  /// Combines two styles; [other] takes precedence where it defines a value.
  FFStyle merge(FFStyle? other) {
    if (other == null) return this;
    return FFStyle(
      padding: padding?.merge(other.padding) ?? other.padding,
      margin: margin?.merge(other.margin) ?? other.margin,
      textStyle: textStyle?.mergeStyles(other.textStyle) ?? other.textStyle,
      color: other.color ?? color,
      fontWeight: FFValue.combine(fontWeight, other.fontWeight),
      fontSize: FFValue.combine(fontSize, other.fontSize),
      lineHeight: FFValue.combine(lineHeight, other.lineHeight),
      textAlign: FFValue.combine(textAlign, other.textAlign),
      backgroundColor: FFValue.combine(backgroundColor, other.backgroundColor),
      backgroundImage: FFValue.combine(backgroundImage, other.backgroundImage),
      shadow: FFValue.combine(shadow, other.shadow),
      borderRadius: FFValue.combine(borderRadius, other.borderRadius),
      borderWidth: FFValue.combine(borderWidth, other.borderWidth),
      borderColor: other.borderColor ?? borderColor,
      width: FFValue.combine(width, other.width),
      minWidth: FFValue.combine(minWidth, other.minWidth),
      maxWidth: FFValue.combine(maxWidth, other.maxWidth),
      height: FFValue.combine(height, other.height),
      maxHeight: FFValue.combine(maxHeight, other.maxHeight),
      visible: FFValue.combine(visible, other.visible),
      clip: FFValue.combine(clip, other.clip),
    );
  }

  /// Flutter `TextStyle` with the values defined by this style for the
  /// current breakpoint and theme mode. Does not include inherited container
  /// styles, so a `Text` using it combines with its container's style.
  TextStyle toTextStyle(BuildContext context) {
    final breakpoint = context.breakpoint;
    final base = textStyle?.resolveMerged(breakpoint) ?? const TextStyle();
    return base.copyWith(
      color: color?.resolve(context),
      fontWeight: fontWeight?.resolve(breakpoint),
      fontSize: fontSize?.resolve(breakpoint),
      height: lineHeight?.resolve(breakpoint),
    );
  }

  /// All values resolved for the current breakpoint and theme mode.
  FFResolvedStyle resolve(BuildContext context) {
    final breakpoint = context.breakpoint;
    return FFResolvedStyle(
      padding: padding?.resolve(breakpoint) ?? EdgeInsets.zero,
      margin: margin?.resolve(breakpoint) ?? EdgeInsets.zero,
      textStyle: toTextStyle(context),
      textAlign: textAlign?.resolve(breakpoint),
      backgroundColor: backgroundColor?.resolve(breakpoint)?.resolve(context),
      backgroundImage: backgroundImage?.resolve(breakpoint),
      shadow: shadow?.resolve(breakpoint) ?? const [],
      borderRadius:
          borderRadius
              ?.resolve(breakpoint)
              ?.resolve(Directionality.of(context)) ??
          BorderRadius.zero,
      borderWidth: borderWidth?.resolve(breakpoint) ?? 0,
      borderColor:
          borderColor?.resolve(context) ??
          Theme.of(context).colorScheme.outlineVariant,
      width: width?.resolve(breakpoint),
      minWidth: minWidth?.resolve(breakpoint),
      maxWidth: maxWidth?.resolve(breakpoint),
      height: height?.resolve(breakpoint),
      maxHeight: maxHeight?.resolve(breakpoint),
      visible: visible?.resolve(breakpoint) ?? true,
      clip: clip?.resolve(breakpoint) ?? false,
    );
  }
}

/// An [FFStyle] with values resolved to standard Flutter types.
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
