import 'package:flutter/widgets.dart';

import '../models/ff_style.dart';

/// Envuelve [child] con los widgets que aplican [style].
///
/// De adentro hacia afuera: texto, padding, recorte, esquinas, borde,
/// fondo, imagen y sombra, tamaño, límites de ancho y alto, y margin. Uso interno de los widgets de la librería.
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
  // Como overflow: hidden. El contenido toma su alto natural y lo que no
  // quepa se corta en el borde del padding.
  if (s.clip) {
    current = UnconstrainedBox(
      constrainedAxis: Axis.horizontal,
      alignment: AlignmentDirectional.topStart,
      clipBehavior: Clip.hardEdge,
      child: current,
    );
  }
  final rounded = s.borderRadius != BorderRadius.zero;
  // Las esquinas recortan por dentro del borde, con el radio interno.
  if (rounded) {
    current = ClipRRect(
      borderRadius: _inner(s.borderRadius, s.borderWidth),
      child: current,
    );
  }
  // El borde va por dentro de la caja, así que se suma al padding.
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

/// [radius] menos el grosor del borde en cada esquina, sin bajar de 0.
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
