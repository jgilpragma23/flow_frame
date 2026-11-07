/// Cómo se muestra un [FFAction] en un breakpoint.
enum FFActionDisplayEnum {
  /// Ícono y texto, como botón.
  full,

  /// Solo el ícono; el texto queda como tooltip.
  icon,

  /// Dentro del menú ⋮, con ícono y texto.
  menu,

  /// No se muestra.
  hidden,
}
