import 'package:flutter/widgets.dart';

/// Nombres de los colores de la paleta.
enum WRColorToken {
  primary,
  secondary,
  background,
  surface,
  text,
  textMuted,
  border,
  error,
  success,
  warning,
}

/// Colores de un modo (claro u oscuro).
@immutable
class WRPalette {
  const WRPalette({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.text,
    required this.textMuted,
    required this.border,
    required this.error,
    required this.success,
    required this.warning,
  });

  /// Paleta clara por defecto.
  static const light = WRPalette(
    primary: Color(0xFF2563EB),
    secondary: Color(0xFF64748B),
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFF5F5F5),
    text: Color(0xFF111111),
    textMuted: Color(0xFF666666),
    border: Color(0xFFE0E0E0),
    error: Color(0xFFDC2626),
    success: Color(0xFF16A34A),
    warning: Color(0xFFD97706),
  );

  /// Paleta oscura por defecto.
  static const dark = WRPalette(
    primary: Color(0xFF60A5FA),
    secondary: Color(0xFF94A3B8),
    background: Color(0xFF0F0F0F),
    surface: Color(0xFF1E1E1E),
    text: Color(0xFFF5F5F5),
    textMuted: Color(0xFF9E9E9E),
    border: Color(0xFF333333),
    error: Color(0xFFF87171),
    success: Color(0xFF4ADE80),
    warning: Color(0xFFFBBF24),
  );

  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color text;
  final Color textMuted;
  final Color border;
  final Color error;
  final Color success;
  final Color warning;

  Color of(WRColorToken token) => switch (token) {
    WRColorToken.primary => primary,
    WRColorToken.secondary => secondary,
    WRColorToken.background => background,
    WRColorToken.surface => surface,
    WRColorToken.text => text,
    WRColorToken.textMuted => textMuted,
    WRColorToken.border => border,
    WRColorToken.error => error,
    WRColorToken.success => success,
    WRColorToken.warning => warning,
  };

  WRPalette copyWith({
    Color? primary,
    Color? secondary,
    Color? background,
    Color? surface,
    Color? text,
    Color? textMuted,
    Color? border,
    Color? error,
    Color? success,
    Color? warning,
  }) => WRPalette(
    primary: primary ?? this.primary,
    secondary: secondary ?? this.secondary,
    background: background ?? this.background,
    surface: surface ?? this.surface,
    text: text ?? this.text,
    textMuted: textMuted ?? this.textMuted,
    border: border ?? this.border,
    error: error ?? this.error,
    success: success ?? this.success,
    warning: warning ?? this.warning,
  );

  @override
  bool operator ==(Object other) =>
      other is WRPalette &&
      WRColorToken.values.every((t) => other.of(t) == of(t));

  @override
  int get hashCode => Object.hashAll(WRColorToken.values.map(of));
}

/// Paletas para el modo claro y el oscuro.
@immutable
class WRColorScheme {
  const WRColorScheme({
    this.light = WRPalette.light,
    this.dark = WRPalette.dark,
  });

  final WRPalette light;
  final WRPalette dark;

  WRPalette of(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  @override
  bool operator ==(Object other) =>
      other is WRColorScheme && other.light == light && other.dark == dark;

  @override
  int get hashCode => Object.hash(light, dark);
}
