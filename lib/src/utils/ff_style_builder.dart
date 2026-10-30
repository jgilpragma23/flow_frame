import 'package:flutter/widgets.dart';

import '../models/ff_style.dart';

/// Envuelve [child] con los widgets que aplican [style].
///
/// De adentro hacia afuera: texto, padding, fondo, tamaño, límites de
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
  if (s.padding != EdgeInsets.zero) {
    current = Padding(padding: s.padding, child: current);
  }
  if (s.backgroundColor != null) {
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
