import 'package:flutter/widgets.dart';

import '../atoms/wr_item.dart';
import '../models/breakpoint.dart';
import '../models/wr_style.dart';
import '../models/wr_value.dart';
import '../utils/context_extensions.dart';
import '../utils/wr_style_builder.dart';

/// Una fila o columna cuya dirección, separación y alineación cambian según
/// el breakpoint (equivale a `d-flex flex-column flex-md-row`).
///
/// Los [WRItem] de [children] pueden repartirse el espacio con `flex`,
/// cambiar de posición con `order` y ocultarse con `visible`; los ocultos no
/// dejan separación. Cualquier otro widget se muestra tal cual.
class WRFlex extends StatelessWidget {
  const WRFlex({
    super.key,
    this.direction = const WRValue.all(Axis.vertical),
    this.gap,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.style,
    required this.children,
  });

  final WRValue<Axis> direction;

  /// Separación entre elementos.
  final WRValue<double>? gap;

  /// Por defecto `start`.
  final WRValue<MainAxisAlignment>? mainAxisAlignment;

  /// Por defecto `stretch` en vertical (los elementos ocupan todo el ancho)
  /// y `start` en horizontal.
  final WRValue<CrossAxisAlignment>? crossAxisAlignment;
  final WRStyle? style;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final breakpoint = context.breakpoint;
    final axis = direction.resolve(breakpoint) ?? Axis.vertical;

    return buildWRStyle(
      context,
      style,
      LayoutBuilder(
        builder: (context, constraints) {
          // Con el eje sin límite (por ejemplo, vertical dentro de un scroll)
          // no hay espacio que repartir y Expanded fallaría.
          final bounded = axis == Axis.horizontal
              ? constraints.hasBoundedWidth
              : constraints.hasBoundedHeight;

          return Flex(
            direction: axis,
            spacing: gap?.resolve(breakpoint) ?? 0,
            mainAxisAlignment:
                mainAxisAlignment?.resolve(breakpoint) ??
                MainAxisAlignment.start,
            crossAxisAlignment:
                crossAxisAlignment?.resolve(breakpoint) ??
                (axis == Axis.vertical
                    ? CrossAxisAlignment.stretch
                    : CrossAxisAlignment.start),
            children: _slots(breakpoint, bounded),
          );
        },
      ),
    );
  }

  /// Quita los ocultos, ordena por `order` y envuelve cada [WRItem] en un
  /// `Flexible`. Cada hijo lleva una key con su índice original para que no
  /// pierda su estado al reordenarse u ocultarse otro.
  List<Widget> _slots(Breakpoint breakpoint, bool bounded) {
    final entries = <({int index, int order, Widget child})>[];
    for (var i = 0; i < children.length; i++) {
      final child = children[i];
      var order = 0;
      if (child is WRItem) {
        if (child.style?.visible?.resolve(breakpoint) == false) continue;
        order = child.order?.resolve(breakpoint) ?? 0;
      }
      entries.add((index: i, order: order, child: child));
    }
    entries.sort(
      (a, b) => a.order != b.order
          ? a.order.compareTo(b.order)
          : a.index.compareTo(b.index),
    );

    return [
      for (final e in entries)
        if (e.child is WRItem)
          Flexible(
            key: _Slot(e.index),
            // flex 0 = tamaño natural, sin cambiar la estructura del árbol.
            flex: bounded
                ? (e.child as WRItem).flex?.resolve(breakpoint) ?? 0
                : 0,
            fit: FlexFit.tight,
            child: e.child,
          )
        else
          KeyedSubtree(key: _Slot(e.index), child: e.child),
    ];
  }
}

class _Slot extends ValueKey<int> {
  const _Slot(super.value);
}
