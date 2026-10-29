import 'package:flutter/material.dart';

/// Un color, opcionalmente con una versión para el modo oscuro.
///
/// El modo se lee del `Theme` de la app (`MaterialApp.themeMode`); la
/// librería no tiene configuración propia de colores.
@immutable
class WRColor {
  /// Un color que no cambia con el modo.
  const WRColor.fixed(Color color) : this.adaptive(light: color, dark: color);

  /// Un color con su versión para el modo claro y para el oscuro.
  const WRColor.adaptive({required Color light, required Color dark})
    : _light = light,
      _dark = dark;

  final Color _light;
  final Color _dark;

  Color resolve(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? _dark : _light;

  @override
  bool operator ==(Object other) =>
      other is WRColor && other._light == _light && other._dark == _dark;

  @override
  int get hashCode => Object.hash(_light, _dark);
}
