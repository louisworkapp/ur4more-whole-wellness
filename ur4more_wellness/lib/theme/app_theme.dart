import 'package:flutter/material.dart';
import 'tokens.dart';
import 'typography.dart';
import 'space.dart';

ThemeData darkFrameTheme(BuildContext ctx) {
  final text = textThemeDark(ctx);
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: T.ink900,
    colorScheme: ColorScheme.dark(
      primary: T.blue,
      secondary: T.blue2,
      surface: T.ink800,
      onSurface: T.ink100,
      outline: T.ink500,
      background: T.ink900,
      onBackground: T.ink100,
      error: T.coral,
      onError: Colors.white,
      tertiary: T.gold,
      onTertiary: Colors.black,
    ),
    textTheme: text,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: text.titleLarge,
      foregroundColor: T.ink100,
    ),
    cardTheme: CardThemeData(
      color: T.ink800,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: Sp.d12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sp.r16)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: T.ink700,
      selectedColor: T.blue.withOpacity(.18),
      labelStyle: text.labelLarge!.copyWith(color: T.ink100),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sp.r12)),
      padding: const EdgeInsets.symmetric(horizontal: Sp.d12, vertical: Sp.d8),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: T.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: Sp.d20, vertical: Sp.d12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        textStyle: text.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: T.ink100,
        side: BorderSide(color: T.ink500),
        padding: const EdgeInsets.symmetric(horizontal: Sp.d20, vertical: Sp.d12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        textStyle: text.labelLarge,
      ),
    ),
    dividerTheme: const DividerThemeData(color: T.ink600, thickness: 1),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: T.ink700,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Sp.r12),
        borderSide: BorderSide(color: T.ink500),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Sp.r12),
        borderSide: BorderSide(color: T.ink500),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Sp.r12),
        borderSide: BorderSide(color: T.blue, width: 2),
      ),
      hintStyle: text.bodyMedium!.copyWith(color: T.ink300),
      labelStyle: text.bodyMedium!.copyWith(color: T.ink300),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: T.ink800,
      indicatorColor: T.blue.withOpacity(.2),
      elevation: 0,
      height: 64,
      iconTheme: WidgetStatePropertyAll(IconThemeData(color: T.ink300)),
      selectedIconTheme: WidgetStatePropertyAll(IconThemeData(color: T.blue)),
      labelTextStyle: WidgetStatePropertyAll(
        text.labelMedium!.copyWith(
          color: T.ink300,
          letterSpacing: 0.4,
        ),
      ),
    ),
  );
}