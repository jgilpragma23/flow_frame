import 'package:flutter/widgets.dart';

import '../models/wr_style.dart';
import '../models/wr_value.dart';
import '../utils/wr_style_builder.dart';

/// Un elemento con estilo responsive, como un `div` con clases.
///
/// Dentro de un `WRFlex`, [col] y [fill] definen su ancho y [order] cambia
/// la posición. Fuera de un `WRFlex` esos tres se ignoran y solo se aplica
/// [style].
///
/// Si en un breakpoint hay [col] y [fill], gana el que esté definido en el
/// breakpoint más cercano al actual; si están en el mismo, gana [col].
class WRItem extends StatelessWidget {
  const WRItem({
    super.key,
    this.col,
    this.fill,
    this.order,
    this.style,
    required this.child,
  });

  /// Cuántas de las 12 columnas ocupa en un `WRFlex` horizontal (como
  /// `col-md-6`). Lo que no cabe en la fila baja a la siguiente. Valores de
  /// 1 a 12. En un `WRFlex` vertical se ignora.
  final WRValue<int>? col;

  /// `true`: ocupa el espacio libre en su fila (o en la columna, si el
  /// `WRFlex` es vertical); si varios lo tienen, se lo reparten en partes
  /// iguales. `false` o sin valor: toma su tamaño natural.
  final WRValue<bool>? fill;

  /// Posición dentro del `WRFlex`; los menores van primero. Por defecto 0.
  final WRValue<int>? order;
  final WRStyle? style;
  final Widget child;

  @override
  Widget build(BuildContext context) => buildWRStyle(context, style, child);
}
