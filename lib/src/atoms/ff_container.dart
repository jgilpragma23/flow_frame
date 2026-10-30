import 'package:flutter/widgets.dart';

import '../models/ff_style.dart';
import '../utils/ff_style_builder.dart';

/// Contenedor principal: ocupa todo el ancho disponible hasta [maxSize],
/// centrado horizontalmente, y aplica [style] por dentro de ese ancho.
///
/// Los `Text` de adentro heredan el estilo de texto de [style].
class FFContainer extends StatelessWidget {
  const FFContainer({super.key, this.maxSize, this.style, required this.child})
    : assert(maxSize == null || maxSize > 0);

  /// Ancho máximo. Si es `null`, el contenedor ocupa todo el ancho.
  final double? maxSize;
  final FFStyle? style;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxSize ?? double.infinity),
        // El style va por fuera del ancho completo: así su maxWidth, minWidth
        // y width limitan la caja, que queda centrada.
        child: buildFFStyle(
          context,
          style,
          SizedBox(width: double.infinity, child: child),
        ),
      ),
    );
  }
}
