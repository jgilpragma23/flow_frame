import 'package:flutter/material.dart';
import 'package:flow_frame/flow_frame.dart';

abstract final class AppColors {
  static const background = FFColor.adaptive(
    light: Color(0xFFFFFFFF),
    dark: Color(0xFF0F0F0F),
  );
  static const surface = FFColor.adaptive(
    light: Color(0xFFF5F5F5),
    dark: Color(0xFF1E1E1E),
  );
  static const primary = FFColor.adaptive(
    light: Color(0xFF2563EB),
    dark: Color(0xFF60A5FA),
  );
  static const muted = FFColor.adaptive(
    light: Color(0xFF666666),
    dark: Color(0xFF9E9E9E),
  );
  static const primarySoft = FFColor.adaptive(
    light: Color(0xFFDBEAFE),
    dark: Color(0xFF1E3A5F),
  );
}
