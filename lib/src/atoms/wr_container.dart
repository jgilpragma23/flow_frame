import 'package:flutter/widgets.dart';

import '../models/wr_padding.dart';
import '../utils/context_extensions.dart';

/// Contenedor principal: ocupa todo el ancho disponible hasta [maxSize],
/// centrado horizontalmente, con un [padding] que cambia por breakpoint.
///
/// El padding queda por dentro del ancho máximo.
class WRContainer extends StatelessWidget {
  const WRContainer({
    super.key,
    this.maxSize,
    this.padding,
    required this.child,
  }) : assert(maxSize == null || maxSize > 0);

  /// Ancho máximo. Si es `null`, el contenedor ocupa todo el ancho.
  final double? maxSize;
  final WRPadding? padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    Widget current = child;

    final insets = padding?.resolve(context.breakpoint);
    if (insets != null && insets != EdgeInsets.zero) {
      current = Padding(padding: insets, child: current);
    }

    return Align(
      alignment: Alignment.topCenter,
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxSize ?? double.infinity),
        child: SizedBox(width: double.infinity, child: current),
      ),
    );
  }
}
