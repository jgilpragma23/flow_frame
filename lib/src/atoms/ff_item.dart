import 'package:flutter/widgets.dart';

import '../models/ff_style.dart';
import '../models/ff_value.dart';
import '../utils/ff_style_builder.dart';

/// Un elemento con estilo responsive, como un `div` con clases.
///
/// Dentro de un `FFFlex`, [col] y [fill] definen su ancho y [order] cambia
/// la posición. Fuera de un `FFFlex` esos tres se ignoran y solo se aplica
/// [style].
///
/// Si en un breakpoint hay [col] y [fill], gana el que esté definido en el
/// breakpoint más cercano al actual; si están en el mismo, gana [col].
class FFItem extends StatelessWidget {
  const FFItem({
    super.key,
    this.col,
    this.fill,
    this.order,
    this.style,
    required this.child,
  });

  /// Cuántas de las 12 columnas ocupa en un `FFFlex` horizontal (como
  /// `col-md-6`). Lo que no cabe en la fila baja a la siguiente. Valores de
  /// 1 a 12. En un `FFFlex` vertical se ignora.
  final FFValue<int>? col;

  /// `true`: ocupa el espacio libre en su fila (o en la columna, si el
  /// `FFFlex` es vertical); si varios lo tienen, se lo reparten en partes
  /// iguales. `false` o sin valor: toma su tamaño natural.
  final FFValue<bool>? fill;

  /// Posición dentro del `FFFlex`; los menores van primero. Por defecto 0.
  final FFValue<int>? order;
  final FFStyle? style;
  final Widget child;

  @override
  Widget build(BuildContext context) => buildFFStyle(context, style, child);
}
