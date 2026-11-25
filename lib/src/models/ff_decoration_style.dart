import 'package:flutter/material.dart';

import '../utils/context_extensions.dart';
import 'ff_color.dart';
import 'ff_value.dart';

/// Responsive paint and shape properties, independent of text and layout.
@immutable
class FFDecorationStyle {
  const FFDecorationStyle({
    this.backgroundColor,
    this.backgroundImage,
    this.shadow,
    this.borderRadius,
    this.borderWidth,
    this.borderColor,
  });

  /// Background color per breakpoint, with optional light/dark variants.
  final FFValue<FFColor>? backgroundColor;

  /// Image painted over [backgroundColor].
  final FFValue<DecorationImage>? backgroundImage;

  final FFValue<List<BoxShadow>>? shadow;
  final FFValue<BorderRadiusGeometry>? borderRadius;
  final FFValue<double>? borderWidth;

  /// Defaults to the theme's `outlineVariant`.
  final FFColor? borderColor;

  FFDecorationStyle merge(FFDecorationStyle? other) {
    if (other == null) return this;
    return FFDecorationStyle(
      backgroundColor: FFValue.combine(backgroundColor, other.backgroundColor),
      backgroundImage: FFValue.combine(backgroundImage, other.backgroundImage),
      shadow: FFValue.combine(shadow, other.shadow),
      borderRadius: FFValue.combine(borderRadius, other.borderRadius),
      borderWidth: FFValue.combine(borderWidth, other.borderWidth),
      borderColor: other.borderColor ?? borderColor,
    );
  }

  FFResolvedDecorationStyle resolve(BuildContext context) {
    final breakpoint = context.breakpoint;
    return FFResolvedDecorationStyle(
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
    );
  }
}

/// Decoration values resolved to standard Flutter types.
@immutable
class FFResolvedDecorationStyle {
  const FFResolvedDecorationStyle({
    this.backgroundColor,
    this.backgroundImage,
    this.shadow = const [],
    this.borderRadius = BorderRadius.zero,
    this.borderWidth = 0,
    this.borderColor = const Color(0x00000000),
  });

  final Color? backgroundColor;
  final DecorationImage? backgroundImage;
  final List<BoxShadow> shadow;
  final BorderRadius borderRadius;
  final double borderWidth;
  final Color borderColor;
}
