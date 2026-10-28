import 'package:flutter/widgets.dart';

import '../models/wr_style.dart';
import '../utils/wr_style_builder.dart';

/// Contenedor principal: ocupa todo el ancho disponible hasta [maxSize],
/// centrado horizontalmente, y aplica [style] por dentro de ese ancho.
///
/// Los `Text` de adentro heredan el estilo de texto de [style].
class WRContainer extends StatelessWidget {
  const WRContainer({super.key, this.maxSize, this.style, required this.child})
    : assert(maxSize == null || maxSize > 0);

  /// Ancho máximo. Si es `null`, el contenedor ocupa todo el ancho.
  final double? maxSize;
  final WRStyle? style;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxSize ?? double.infinity),
        child: SizedBox(
          width: double.infinity,
          child: buildWRStyle(context, style, child),
        ),
      ),
    );
  }
}
