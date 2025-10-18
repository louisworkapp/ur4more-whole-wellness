import 'package:flutter/material.dart';
import 'tokens.dart';

/// Temporary compatibility layer for old AppTheme references
/// This allows the app to compile while we migrate to the new token system
class AppTheme {
  // Light theme colors
  static const Color primaryLight = Color(0xFF1E3A8A);
  static const Color secondaryLight = Color(0xFFF5C542);
  static const Color successLight = Color(0xFF10B981);
  static const Color errorLight = Color(0xFFEF4444);
  
  // Light theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.light(
      primary: primaryLight,
      secondary: secondaryLight,
      surface: Colors.white,
      onSurface: const Color(0xFF0B1220),
      background: Colors.white,
      onBackground: const Color(0xFF0B1220),
      tertiary: secondaryLight,
      onTertiary: Colors.black,
    ),
  );
}
