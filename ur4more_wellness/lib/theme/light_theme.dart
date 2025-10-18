import 'package:flutter/material.dart';
import 'app_theme.dart';

ThemeData buildLightTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF1E3A8A),
      secondary: const Color(0xFFF5C542),
      surface: Colors.white,
      onSurface: const Color(0xFF0B1220),
      background: Colors.white,
      onBackground: const Color(0xFF0B1220),
    ),
  );
}
