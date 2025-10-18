import 'package:flutter/material.dart';

class Brand {
  // Ink / Indigo
  static const ink    = Color(0xFF0E1420);
  static const ink2   = Color(0xFF121A2A);
  static const card   = Color(0xFF1A2234);
  static const primary= Color(0xFF1F4ED3);
  static const indigo = primary;
  static const accent = Color(0xFF7FA4FF);
  static const mint   = Color(0xFF3AD1C3);
  static const onDark = Color(0xFFE8ECF5);
  static const onDarkMuted = Color(0xFF9AA6BF);
  static const stroke = Color(0x10FFFFFF); // subtle 6–10% white

  static const radius = 20.0;
  static const gap = 12.0;

  static const shadow = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 24,
      offset: Offset(0, 12),
    ),
  ];
}

TextTheme brandText(final Color on) => TextTheme(
  headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: on),
  headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: on),
  titleLarge:    TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: on),
  titleMedium:   TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: on),
  bodyLarge:     TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Brand.onDark),
  bodyMedium:    TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Brand.onDarkMuted),
  labelLarge:    TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: .2, color: on),
  labelSmall:    TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: .3, color: on),
);
