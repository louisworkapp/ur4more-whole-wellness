import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tokens.dart';

TextTheme textThemeDark(BuildContext _) {
  final base = GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme);
  return base.copyWith(
    displaySmall: base.displaySmall?.copyWith(
      fontWeight: FontWeight.w700, 
      letterSpacing: -0.4,
      color: T.ink100,
    ),
    headlineMedium: base.headlineMedium?.copyWith(
      fontWeight: FontWeight.w700, 
      letterSpacing: -0.2,
      color: T.ink100,
    ),
    titleLarge: base.titleLarge?.copyWith(
      fontWeight: FontWeight.w600,
      color: T.ink100,
    ),
    titleMedium: base.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: T.ink100,
    ),
    bodyLarge: base.bodyLarge?.copyWith(
      height: 1.35,
      color: T.ink200,
    ),
    bodyMedium: base.bodyMedium?.copyWith(
      color: T.ink200,
    ),
    labelLarge: base.labelLarge?.copyWith(
      fontWeight: FontWeight.w700, 
      letterSpacing: 0.4,
      color: T.ink100,
    ),
    labelMedium: base.labelMedium?.copyWith(
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
      color: T.ink300,
    ),
  );
}
