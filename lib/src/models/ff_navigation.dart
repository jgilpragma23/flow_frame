import 'package:flutter/widgets.dart';

import '../enums/breakpoint_enum.dart';
import '../enums/ff_navigation_enum.dart';
import '../enums/ff_rail_expand_enum.dart';
import 'ff_color.dart';
import 'ff_value.dart';

export '../enums/ff_navigation_enum.dart';
export '../enums/ff_rail_expand_enum.dart';

/// Cómo se ve y se comporta la navegación de un `FFScaffold` en un
/// breakpoint. Se usa dentro de un `FFValue`, en cascada: cada breakpoint
/// pone solo lo que cambia y hereda el resto de los menores.
@immutable
class FFNavStyle {
  const FFNavStyle({
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
    this.shadow,
    this.shadowColor,
  });

  /// Barra abajo, rail, drawer o enlaces en el app bar.
  final FFNavigationEnum? type;

  /// Con rail, si el menú completo se abre encima o como sidebar.
  final FFRailExpandEnum? expandMode;

  /// Con [FFRailExpandEnum.sidebar], si el menú empieza abierto. Al cambiar de
  /// breakpoint vuelve a este valor.
  final bool? expanded;

  /// Si los grupos están siempre abiertos, sin flecha.
  /// `FFDestination.alwaysOpen` tiene prioridad.
  final bool? subRoutesAlwaysVisible;

  /// Fondo de la barra, el rail y el menú. Con [FFNavigationEnum.appBar], fondo
  /// del app bar si este no define el suyo.
  final FFColor? backgroundColor;
  final FFColor? iconColor;
  final FFColor? labelColor;

  /// Fondo del indicador del destino seleccionado.
  final FFColor? selectedBackgroundColor;
  final FFColor? selectedIconColor;
  final FFColor? selectedLabelColor;

  /// Sombra que separa la navegación del contenido: a la derecha del rail
  /// y del sidebar, y arriba de la barra. Por defecto sin sombra.
  final bool? shadow;

  /// Color de la sombra. Por defecto el `shadow` del `ColorScheme`, suave.
  final FFColor? shadowColor;

  /// Los valores de [other] reemplazan a los de este, salvo los `null`.
  FFNavStyle merge(FFNavStyle? other) {
    if (other == null) return this;
    return FFNavStyle(
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
      shadow: other.shadow ?? shadow,
      shadowColor: other.shadowColor ?? shadowColor,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is FFNavStyle &&
      other.type == type &&
      other.expandMode == expandMode &&
      other.expanded == expanded &&
      other.subRoutesAlwaysVisible == subRoutesAlwaysVisible &&
      other.backgroundColor == backgroundColor &&
      other.iconColor == iconColor &&
      other.labelColor == labelColor &&
      other.selectedBackgroundColor == selectedBackgroundColor &&
      other.selectedIconColor == selectedIconColor &&
      other.selectedLabelColor == selectedLabelColor &&
      other.shadow == shadow &&
      other.shadowColor == shadowColor;

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
    shadow,
    shadowColor,
  );
}

/// Combina en cascada los [FFNavStyle] de un `FFValue`.
extension FFNavStyleValue on FFValue<FFNavStyle> {
  /// Une los estilos desde `xs` hasta [breakpoint]; los mayores ganan.
  FFNavStyle resolveMerged(BreakpointEnum breakpoint) {
    var result = const FFNavStyle();
    for (var i = 0; i <= breakpoint.index; i++) {
      result = result.merge(at(BreakpointEnum.values[i]));
    }
    return result;
  }
}

/// Un destino de la navegación. Si tiene [children], es un grupo: en el
/// menú completo se muestra como acordeón y no es una página por sí mismo.
@immutable
class FFDestination {
  const FFDestination({
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
  final List<FFDestination> children;

  /// `false` lo oculta en ese breakpoint. Por defecto visible.
  final FFValue<bool>? visible;

  /// Si el grupo está siempre abierto, sin flecha para cerrarlo. Si es
  /// `null` se usa `FFNavStyle.subRoutesAlwaysVisible`.
  final bool? alwaysOpen;

  bool get isGroup => children.isNotEmpty;
}
