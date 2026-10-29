import 'package:flutter/widgets.dart';

/// La marca de la app (logo y nombre) que acompaña al botón ☰ de un
/// `FFScaffold`. Se define una vez y cada tipo de navegación la acomoda:
///
/// - sidebar y overlay: logo, [title] y [subtitle] en el encabezado del menú;
/// - rail cerrado: solo el [logo], debajo del ☰;
/// - drawer: logo y [title] en el app bar, y la marca completa arriba del
///   drawer (si [showInDrawer]);
/// - appBar: logo y [title] antes de los enlaces;
/// - bottom: logo y [title] en el app bar.
///
/// En el app bar solo se usa si el `AppBar` no tiene `title`; el título
/// propio siempre manda.
@immutable
class FFBrand {
  const FFBrand({
    this.logo,
    this.title,
    this.subtitle,
    this.onTap,
    this.showInDrawer = true,
  }) : assert(logo != null || title != null);

  /// Ícono o imagen; en el rail cerrado es lo único que se muestra.
  final Widget? logo;
  final Widget? title;

  /// Debajo de [title], solo en el menú (sidebar, overlay y drawer).
  final Widget? subtitle;

  /// Por ejemplo, ir al inicio.
  final VoidCallback? onTap;

  /// Con `FFNavigation.drawer`, si se repite arriba dentro del drawer
  /// además del app bar.
  final bool showInDrawer;
}
