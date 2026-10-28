import 'package:flutter/widgets.dart';

import '../utils/context_extensions.dart';
import 'wr_palette.dart';

/// Un color que se resuelve según el modo claro u oscuro.
///
/// Puede ser un color de la paleta del tema (`WRColor.primary`), un par
/// claro/oscuro (`WRColor.adaptive`) o un color fijo (`WRColor.fixed`).
@immutable
class WRColor {
  /// Un color que no cambia con el tema.
  const WRColor.fixed(Color color) : this.adaptive(light: color, dark: color);

  /// Un color con su versión para el modo claro y para el oscuro.
  const WRColor.adaptive({
    required Color this._light,
    required Color this._dark,
  }) : _token = null;

  /// Un color de la paleta del tema.
  const WRColor.token(WRColorToken token)
    : _token = token,
      _light = null,
      _dark = null;

  static const primary = WRColor.token(WRColorToken.primary);
  static const secondary = WRColor.token(WRColorToken.secondary);
  static const background = WRColor.token(WRColorToken.background);
  static const surface = WRColor.token(WRColorToken.surface);
  static const text = WRColor.token(WRColorToken.text);
  static const textMuted = WRColor.token(WRColorToken.textMuted);
  static const border = WRColor.token(WRColorToken.border);
  static const error = WRColor.token(WRColorToken.error);
  static const success = WRColor.token(WRColorToken.success);
  static const warning = WRColor.token(WRColorToken.warning);

  final WRColorToken? _token;
  final Color? _light;
  final Color? _dark;

  Color resolve(BuildContext context) {
    final token = _token;
    if (token != null) return context.wrColors.of(token);
    return context.wrBrightness == Brightness.dark ? _dark! : _light!;
  }

  @override
  bool operator ==(Object other) =>
      other is WRColor &&
      other._token == _token &&
      other._light == _light &&
      other._dark == _dark;

  @override
  int get hashCode => Object.hash(_token, _light, _dark);
}
