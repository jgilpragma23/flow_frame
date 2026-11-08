import 'package:flutter/material.dart';

/// A color, optionally with a dark-mode variant.
///
/// The mode is read from the app's `Theme` (`MaterialApp.themeMode`); the
/// package has no separate color configuration.
@immutable
class FFColor {
  /// A color that does not change with the mode.
  const FFColor.fixed(Color color) : this.adaptive(light: color, dark: color);

  /// A color with light- and dark-mode variants.
  const FFColor.adaptive({required Color light, required Color dark})
    : _light = light,
      _dark = dark;

  final Color _light;
  final Color _dark;

  Color resolve(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? _dark : _light;

  @override
  bool operator ==(Object other) =>
      other is FFColor && other._light == _light && other._dark == _dark;

  @override
  int get hashCode => Object.hash(_light, _dark);
}
