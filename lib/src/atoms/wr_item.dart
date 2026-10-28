import 'package:flutter/widgets.dart';

import '../models/wr_style.dart';
import '../models/wr_value.dart';
import '../utils/wr_style_builder.dart';

/// Un elemento con estilo responsive, como un `div` con clases.
///
/// Dentro de un `WRFlex`, [flex] reparte el espacio libre y [order] cambia
/// la posición. Fuera de un `WRFlex` esos dos se ignoran y solo se aplica
/// [style].
class WRItem extends StatelessWidget {
  const WRItem({
    super.key,
    this.flex,
    this.order,
    this.style,
    required this.child,
  });

  /// Parte del espacio libre que ocupa en el eje del `WRFlex`. Sin valor en
  /// un breakpoint, el elemento toma su tamaño natural.
  final WRValue<int>? flex;

  /// Posición dentro del `WRFlex`; los menores van primero. Por defecto 0.
  final WRValue<int>? order;
  final WRStyle? style;
  final Widget child;

  @override
  Widget build(BuildContext context) => buildWRStyle(context, style, child);
}
