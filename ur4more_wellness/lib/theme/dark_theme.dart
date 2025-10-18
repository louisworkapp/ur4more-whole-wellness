import 'package:flutter/material.dart';
import 'brand_tokens.dart';

ThemeData buildDarkTheme() {
  final color = ColorScheme(
    brightness: Brightness.dark,
    primary: Brand.primary,
    onPrimary: Colors.white,
    secondary: Brand.accent,
    onSecondary: Colors.white,
    surface: Brand.ink2,
    onSurface: Brand.onDark,
    background: Brand.ink,
    onBackground: Brand.onDark,
    error: const Color(0xFFEF5350),
    onError: Colors.white,
    tertiary: Brand.mint,
    onTertiary: Colors.black,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: color,
    scaffoldBackgroundColor: Brand.ink,
    canvasColor: Brand.ink,
    textTheme: brandText(Brand.onDark),
    appBarTheme: AppBarTheme(
      backgroundColor: Brand.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: brandText(Brand.onDark).headlineMedium,
      foregroundColor: Brand.onDark,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: Brand.card,
      elevation: 0,
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Brand.radius),
        side: const BorderSide(color: Brand.stroke),
      ),
      shadowColor: Colors.black,
    ),
    dividerColor: Brand.stroke,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Brand.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Brand.onDark,
        side: const BorderSide(color: Brand.stroke),
        backgroundColor: const Color(0x14FFFFFF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Brand.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Brand.stroke),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Brand.stroke),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Brand.accent, width: 1.2),
      ),
      hintStyle: TextStyle(color: Brand.onDarkMuted),
      labelStyle: TextStyle(color: Brand.onDarkMuted),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0x14FFFFFF),
      labelStyle: TextStyle(color: Brand.onDark),
      selectedColor: Brand.primary.withOpacity(.25),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(Brand.onDark),
        overlayColor: WidgetStatePropertyAll(Colors.white.withOpacity(.06)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Brand.ink2,
      indicatorColor: Brand.primary.withOpacity(.20),
      elevation: 0,
      height: 64,
      iconTheme: WidgetStatePropertyAll(IconThemeData(color: Brand.onDark)),
      labelTextStyle: WidgetStatePropertyAll(brandText(Brand.onDarkMuted).labelSmall),
    ),
  );
}
