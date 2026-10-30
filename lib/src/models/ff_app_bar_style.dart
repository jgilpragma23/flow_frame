import 'package:flutter/widgets.dart';

import 'breakpoint.dart';
import 'ff_color.dart';
import 'ff_value.dart';

/// Cómo se ve un `FFAppBar` en un breakpoint. Se usa dentro de un
/// `FFValue`, en cascada: cada breakpoint pone solo lo que cambia y hereda
/// el resto de los menores.
@immutable
class FFAppBarStyle {
  const FFAppBarStyle({
    this.visible,
    this.showBrand,
    this.showTitle,
    this.centerTitle,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.linkColor,
    this.selectedLinkColor,
    this.selectedLinkBackgroundColor,
  });

  /// `false` oculta el app bar completo y el contenido sube. Por defecto
  /// visible.
  final bool? visible;

  /// `false` oculta la marca. Por defecto visible.
  final bool? showBrand;

  /// `false` oculta el título. Por defecto visible.
  final bool? showTitle;

  /// Si la marca y el título van al centro. Por defecto a la izquierda, en
  /// todas las plataformas; con enlaces siempre van a la izquierda.
  final bool? centerTitle;
  final FFColor? backgroundColor;

  /// Color de los íconos y del texto del título.
  final FFColor? foregroundColor;
  final double? elevation;

  /// Texto e íconos de los enlaces.
  final FFColor? linkColor;
  final FFColor? selectedLinkColor;

  /// Fondo del enlace de la ruta actual.
  final FFColor? selectedLinkBackgroundColor;

  /// Los valores de [other] reemplazan a los de este, salvo los `null`.
  FFAppBarStyle merge(FFAppBarStyle? other) {
    if (other == null) return this;
    return FFAppBarStyle(
      visible: other.visible ?? visible,
      showBrand: other.showBrand ?? showBrand,
      showTitle: other.showTitle ?? showTitle,
      centerTitle: other.centerTitle ?? centerTitle,
      backgroundColor: other.backgroundColor ?? backgroundColor,
      foregroundColor: other.foregroundColor ?? foregroundColor,
      elevation: other.elevation ?? elevation,
      linkColor: other.linkColor ?? linkColor,
      selectedLinkColor: other.selectedLinkColor ?? selectedLinkColor,
      selectedLinkBackgroundColor:
          other.selectedLinkBackgroundColor ?? selectedLinkBackgroundColor,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is FFAppBarStyle &&
      other.visible == visible &&
      other.showBrand == showBrand &&
      other.showTitle == showTitle &&
      other.centerTitle == centerTitle &&
      other.backgroundColor == backgroundColor &&
      other.foregroundColor == foregroundColor &&
      other.elevation == elevation &&
      other.linkColor == linkColor &&
      other.selectedLinkColor == selectedLinkColor &&
      other.selectedLinkBackgroundColor == selectedLinkBackgroundColor;

  @override
  int get hashCode => Object.hash(
    visible,
    showBrand,
    showTitle,
    centerTitle,
    backgroundColor,
    foregroundColor,
    elevation,
    linkColor,
    selectedLinkColor,
    selectedLinkBackgroundColor,
  );
}

/// Combina en cascada los [FFAppBarStyle] de un `FFValue`.
extension FFAppBarStyleValue on FFValue<FFAppBarStyle> {
  /// Une los estilos desde `xs` hasta [breakpoint]; los mayores ganan.
  FFAppBarStyle resolveMerged(Breakpoint breakpoint) {
    var result = const FFAppBarStyle();
    for (var i = 0; i <= breakpoint.index; i++) {
      result = result.merge(at(Breakpoint.values[i]));
    }
    return result;
  }
}
