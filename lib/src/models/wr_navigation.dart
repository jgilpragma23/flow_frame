import 'package:flutter/widgets.dart';

import 'breakpoint.dart';
import 'wr_color.dart';
import 'wr_value.dart';

/// Tipo de navegación de un `WRScaffold`. Se elige uno por breakpoint.
enum WRNavigation {
  /// Barra abajo con íconos y textos (`NavigationBar`). Las subrutas no se
  /// muestran: tocar un grupo lleva a su última subruta visitada (o a la
  /// primera).
  bottom,

  /// Barra lateral fija de íconos con un botón ☰ que abre el menú completo,
  /// encima del contenido o empujándolo según [WRRailExpand].
  rail,

  /// Menú oculto que sale desde el lado al tocar ☰ en el app bar.
  drawer,
}

/// Cómo se abre el menú completo (con textos y acordeón) desde el rail.
enum WRRailExpand {
  /// Se abre un drawer encima del contenido, que no se mueve. Se cierra al
  /// elegir una opción o al tocar fuera.
  overlay,

  /// El rail se ensancha y empuja el contenido. Queda abierto hasta que se
  /// cierre con ☰.
  sidebar,
}

/// Cómo se ve y se comporta la navegación de un `WRScaffold` en un
/// breakpoint. Se usa dentro de un `WRValue`, en cascada: cada breakpoint
/// pone solo lo que cambia y hereda el resto de los menores.
@immutable
class WRNavStyle {
  const WRNavStyle({
    this.type,
    this.expandMode,
    this.expanded,
    this.subRoutesAlwaysVisible,
    this.backgroundColor,
    this.iconColor,
    this.labelColor,
    this.selectedBackgroundColor,
    this.selectedIconColor,
    this.selectedLabelColor,
  });

  /// Barra abajo, rail o drawer.
  final WRNavigation? type;

  /// Con rail, si el menú completo se abre encima o como sidebar.
  final WRRailExpand? expandMode;

  /// Con [WRRailExpand.sidebar], si el menú empieza abierto. Al cambiar de
  /// breakpoint vuelve a este valor.
  final bool? expanded;

  /// Si los grupos están siempre abiertos, sin flecha.
  /// `WRDestination.alwaysOpen` tiene prioridad.
  final bool? subRoutesAlwaysVisible;

  /// Fondo de la barra, el rail y el menú.
  final WRColor? backgroundColor;
  final WRColor? iconColor;
  final WRColor? labelColor;

  /// Fondo del indicador del destino seleccionado.
  final WRColor? selectedBackgroundColor;
  final WRColor? selectedIconColor;
  final WRColor? selectedLabelColor;

  /// Los valores de [other] reemplazan a los de este, salvo los `null`.
  WRNavStyle merge(WRNavStyle? other) {
    if (other == null) return this;
    return WRNavStyle(
      type: other.type ?? type,
      expandMode: other.expandMode ?? expandMode,
      expanded: other.expanded ?? expanded,
      subRoutesAlwaysVisible:
          other.subRoutesAlwaysVisible ?? subRoutesAlwaysVisible,
      backgroundColor: other.backgroundColor ?? backgroundColor,
      iconColor: other.iconColor ?? iconColor,
      labelColor: other.labelColor ?? labelColor,
      selectedBackgroundColor:
          other.selectedBackgroundColor ?? selectedBackgroundColor,
      selectedIconColor: other.selectedIconColor ?? selectedIconColor,
      selectedLabelColor: other.selectedLabelColor ?? selectedLabelColor,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is WRNavStyle &&
      other.type == type &&
      other.expandMode == expandMode &&
      other.expanded == expanded &&
      other.subRoutesAlwaysVisible == subRoutesAlwaysVisible &&
      other.backgroundColor == backgroundColor &&
      other.iconColor == iconColor &&
      other.labelColor == labelColor &&
      other.selectedBackgroundColor == selectedBackgroundColor &&
      other.selectedIconColor == selectedIconColor &&
      other.selectedLabelColor == selectedLabelColor;

  @override
  int get hashCode => Object.hash(
    type,
    expandMode,
    expanded,
    subRoutesAlwaysVisible,
    backgroundColor,
    iconColor,
    labelColor,
    selectedBackgroundColor,
    selectedIconColor,
    selectedLabelColor,
  );
}

/// Combina en cascada los [WRNavStyle] de un `WRValue`.
extension WRNavStyleValue on WRValue<WRNavStyle> {
  /// Une los estilos desde `xs` hasta [breakpoint]; los mayores ganan.
  WRNavStyle resolveMerged(Breakpoint breakpoint) {
    var result = const WRNavStyle();
    for (var i = 0; i <= breakpoint.index; i++) {
      result = result.merge(at(Breakpoint.values[i]));
    }
    return result;
  }
}

/// Un destino de la navegación. Si tiene [children], es un grupo: en el
/// menú completo se muestra como acordeón y no es una página por sí mismo.
@immutable
class WRDestination {
  const WRDestination({
    required this.id,
    required this.icon,
    this.selectedIcon,
    required this.label,
    this.children = const [],
    this.visible,
    this.alwaysOpen,
  });

  /// Identificador único; es lo que reciben `currentRoute` y
  /// `onRouteSelected`.
  final String id;
  final Widget icon;

  /// Ícono cuando está seleccionado. Si es `null` se usa [icon].
  final Widget? selectedIcon;
  final String label;

  /// Subrutas (un solo nivel). Las subrutas de las subrutas se ignoran.
  final List<WRDestination> children;

  /// `false` lo oculta en ese breakpoint. Por defecto visible.
  final WRValue<bool>? visible;

  /// Si el grupo está siempre abierto, sin flecha para cerrarlo. Si es
  /// `null` se usa `WRNavStyle.subRoutesAlwaysVisible`.
  final bool? alwaysOpen;

  bool get isGroup => children.isNotEmpty;
}
