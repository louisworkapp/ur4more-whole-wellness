import 'package:flutter/material.dart';

class MindColors {
  static const bg = Color(0xFF0C1220);
  static const surface = Color(0xFF121A2B);
  static const surfaceHover = Color(0xFF172238);
  static const outline = Color(0xFF243356);
  static const text = Color(0xFFEAF1FF);
  static const textSub = Color(0xFFA8B7D6);

  static const brandBlue = Color(0xFF3C79FF);
  static const blue200 = Color(0xFF7AA9FF);

  static const lime = Color(0xFFA7FF4B);
  static const limePressed = Color(0xFF7DCB2E);
}

ThemeData buildMindTheme(ThemeData base) {
  final scheme = const ColorScheme.dark(
    background: MindColors.bg,
    surface: MindColors.surface,
    primary: MindColors.brandBlue,
    secondary: MindColors.lime,
    onBackground: MindColors.text,
    onSurface: MindColors.text,
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    outline: MindColors.outline,
  );
  return base.copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: MindColors.bg,
    textTheme: base.textTheme.apply(
      bodyColor: MindColors.text,
      displayColor: MindColors.text,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: MindColors.lime,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        elevation: 0,
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: MindColors.surfaceHover,
      border: OutlineInputBorder(
        borderSide: BorderSide(color: MindColors.outline),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: MindColors.outline),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: MindColors.brandBlue, width: 1.5),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    ),
    dividerColor: MindColors.outline,
  );
}