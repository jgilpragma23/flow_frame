import 'package:flutter/widgets.dart';

/// Dirección de un `FFFlex`, como `flex-row`, `flex-row-reverse`,
/// `flex-column` y `flex-column-reverse` de Bootstrap.
enum FFDirection {
  /// En filas de 12 columnas; lo que no cabe baja a la siguiente.
  horizontal,

  /// Como [horizontal], con los hijos en orden inverso: en una fila el
  /// último queda a la izquierda y, apilados, el último queda arriba.
  horizontalReverse,

  /// Apilados de arriba hacia abajo.
  vertical,

  /// Apilados de abajo hacia arriba.
  verticalReverse;

  Axis get axis => switch (this) {
    horizontal || horizontalReverse => Axis.horizontal,
    vertical || verticalReverse => Axis.vertical,
  };

  bool get isReverse => this == horizontalReverse || this == verticalReverse;
}
