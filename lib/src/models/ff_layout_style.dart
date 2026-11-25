import 'package:flutter/widgets.dart';

import '../utils/context_extensions.dart';
import 'ff_spacing.dart';
import 'ff_value.dart';

/// Responsive spacing, dimensions, clipping, and visibility.
@immutable
class FFLayoutStyle {
  const FFLayoutStyle({
    this.padding,
    this.margin,
    this.width,
    this.minWidth,
    this.maxWidth,
    this.height,
    this.maxHeight,
    this.visible,
    this.clip,
  });

  final FFSpacing? padding;
  final FFSpacing? margin;
  final FFValue<double>? width;
  final FFValue<double>? minWidth;
  final FFValue<double>? maxWidth;
  final FFValue<double>? height;
  final FFValue<double>? maxHeight;

  /// Whether this subtree is included at the active breakpoint.
  final FFValue<bool>? visible;

  /// Clips content to the resolved bounds.
  final FFValue<bool>? clip;

  FFLayoutStyle merge(FFLayoutStyle? other) {
    if (other == null) return this;
    return FFLayoutStyle(
      padding: padding?.merge(other.padding) ?? other.padding,
      margin: margin?.merge(other.margin) ?? other.margin,
      width: FFValue.combine(width, other.width),
      minWidth: FFValue.combine(minWidth, other.minWidth),
      maxWidth: FFValue.combine(maxWidth, other.maxWidth),
      height: FFValue.combine(height, other.height),
      maxHeight: FFValue.combine(maxHeight, other.maxHeight),
      visible: FFValue.combine(visible, other.visible),
      clip: FFValue.combine(clip, other.clip),
    );
  }

  FFResolvedLayoutStyle resolve(BuildContext context) {
    final breakpoint = context.breakpoint;
    return FFResolvedLayoutStyle(
      padding: padding?.resolve(breakpoint) ?? EdgeInsets.zero,
      margin: margin?.resolve(breakpoint) ?? EdgeInsets.zero,
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

/// Layout values resolved to standard Flutter types.
@immutable
class FFResolvedLayoutStyle {
  const FFResolvedLayoutStyle({
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
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
  final double? width;
  final double? minWidth;
  final double? maxWidth;
  final double? height;
  final double? maxHeight;
  final bool visible;
  final bool clip;
}
