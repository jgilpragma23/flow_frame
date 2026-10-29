import 'package:flutter/widgets.dart';

import '../utils/context_extensions.dart';
import 'ff_color.dart';
import 'ff_spacing.dart';
import 'ff_value.dart';

/// Estilo responsive reutilizable, parecido a una clase de CSS.
///
/// Para el texto, [textStyle] es la base y [color], [fontWeight], [fontSize]
/// y [lineHeight] se aplican encima.
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
    this.width,
    this.minWidth,
    this.maxWidth,
    this.height,
    this.visible,
  });

  final FFSpacing? padding;
  final FFSpacing? margin;

  /// Estilo de texto base. En cada breakpoint se combinan los estilos desde
  /// `xs`, así que lo que se define en `xs` no se pierde en `md`.
  final FFValue<TextStyle>? textStyle;

  /// Color del texto; sigue al modo claro/oscuro.
  final FFColor? color;
  final FFValue<FontWeight>? fontWeight;
  final FFValue<double>? fontSize;

  /// Alto de línea, como múltiplo del tamaño de la fuente.
  final FFValue<double>? lineHeight;
  final FFValue<TextAlign>? textAlign;

  final FFColor? backgroundColor;

  final FFValue<double>? width;
  final FFValue<double>? minWidth;
  final FFValue<double>? maxWidth;
  final FFValue<double>? height;

  /// `false` oculta el widget en ese breakpoint (equivale a `d-none`).
  final FFValue<bool>? visible;

  /// Combina dos estilos; [other] gana donde define algo.
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
      backgroundColor: other.backgroundColor ?? backgroundColor,
      width: FFValue.combine(width, other.width),
      minWidth: FFValue.combine(minWidth, other.minWidth),
      maxWidth: FFValue.combine(maxWidth, other.maxWidth),
      height: FFValue.combine(height, other.height),
      visible: FFValue.combine(visible, other.visible),
    );
  }

  /// `TextStyle` de Flutter con lo que define este estilo para el breakpoint
  /// y el modo actuales. No incluye lo heredado de los contenedores, así que
  /// al usarlo en un `Text` se combina con el estilo del contenedor.
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

  /// Todos los valores ya calculados para el breakpoint y el modo actuales.
  WRResolvedStyle resolve(BuildContext context) {
    final breakpoint = context.breakpoint;
    return WRResolvedStyle(
      padding: padding?.resolve(breakpoint) ?? EdgeInsets.zero,
      margin: margin?.resolve(breakpoint) ?? EdgeInsets.zero,
      textStyle: toTextStyle(context),
      textAlign: textAlign?.resolve(breakpoint),
      backgroundColor: backgroundColor?.resolve(context),
      width: width?.resolve(breakpoint),
      minWidth: minWidth?.resolve(breakpoint),
      maxWidth: maxWidth?.resolve(breakpoint),
      height: height?.resolve(breakpoint),
      visible: visible?.resolve(breakpoint) ?? true,
    );
  }
}

/// Un [FFStyle] con valores normales de Flutter, ya calculados.
@immutable
class WRResolvedStyle {
  const WRResolvedStyle({
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.textStyle = const TextStyle(),
    this.textAlign,
    this.backgroundColor,
    this.width,
    this.minWidth,
    this.maxWidth,
    this.height,
    this.visible = true,
  });

  final EdgeInsets padding;
  final EdgeInsets margin;
  final TextStyle textStyle;
  final TextAlign? textAlign;
  final Color? backgroundColor;
  final double? width;
  final double? minWidth;
  final double? maxWidth;
  final double? height;
  final bool visible;
}
