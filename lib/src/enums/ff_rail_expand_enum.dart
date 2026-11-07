/// Cómo se abre el menú completo (con textos y acordeón) desde el rail.
enum FFRailExpandEnum {
  /// Se abre un drawer encima del contenido, que no se mueve. Se cierra al
  /// elegir una opción o al tocar fuera.
  overlay,

  /// El rail se ensancha y empuja el contenido. Queda abierto hasta que se
  /// cierre con ☰.
  sidebar,
}
