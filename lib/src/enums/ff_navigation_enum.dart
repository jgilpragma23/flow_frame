import 'ff_rail_expand_enum.dart';

/// Tipo de navegación de un `FFScaffold`. Se elige uno por breakpoint.
enum FFNavigationEnum {
  /// Barra abajo con íconos y textos (`NavigationBar`). Las subrutas no se
  /// muestran: tocar un grupo lleva a su última subruta visitada (o a la
  /// primera).
  bottom,

  /// Barra lateral fija de íconos con un botón ☰ que abre el menú completo,
  /// encima del contenido o empujándolo según [FFRailExpandEnum].
  rail,

  /// Menú oculto que sale desde el lado al tocar ☰ en el app bar.
  drawer,

  /// Enlaces dentro del app bar, después del título, como en un sitio web.
  /// Un grupo es un botón con ▾ que abre un dropdown con sus subrutas.
  /// Pensado para pantallas medianas y grandes.
  appBar,
}
