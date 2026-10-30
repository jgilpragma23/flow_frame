import 'package:flutter/widgets.dart';

import '../models/ff_style.dart';

/// Envuelve [child] con los widgets que aplican [style].
///
/// De adentro hacia afuera: texto, padding, fondo e imagen, borde, esquinas y sombra, tamaño, límites de
/// ancho y alto, y margin. Uso interno de los widgets de la librería.
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
  // El borde va por dentro de la caja, así que se suma al padding.
  final padding = s.padding + EdgeInsets.all(s.borderWidth);
  if (padding != EdgeInsets.zero) {
    current = Padding(padding: padding, child: current);
  }
  final radius = BorderRadius.circular(s.borderRadius);
  if (s.borderRadius > 0) {
    current = ClipRRect(borderRadius: radius, child: current);
  }
  if (s.backgroundImage != null ||
      s.shadow.isNotEmpty ||
      s.borderRadius > 0 ||
      s.borderWidth > 0) {
    current = DecoratedBox(
      decoration: BoxDecoration(
        color: s.backgroundColor,
        image: s.backgroundImage,
        boxShadow: s.shadow,
        borderRadius: s.borderRadius > 0 ? radius : null,
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
