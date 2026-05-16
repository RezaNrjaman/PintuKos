import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF006065);
  static const Color primaryContainer = Color(0xFF0D7A80);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8F9FF);
  static const Color surface = Color(0xFFF8F9FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainer = Color(0xFFE6EEFF);
  static const Color surfaceContainerHigh = Color(0xFFDEE9FC);
  static const Color onSurface = Color(0xFF121C2A);
  static const Color onSurfaceVariant = Color(0xFF3E4949);
  static const Color outline = Color(0xFF6E797A);
  static const Color outlineVariant = Color(0xFFBDC9C9);
  static const Color secondaryContainer = Color(0xFF5DFD8A);
  static const Color onSecondaryContainer = Color(0xFF007232);
  static const Color primaryFixedDim = Color(0xFF7DD4DB);
  static const Color onPrimaryFixed = Color(0xFF002022);
  static const Color error = Color(0xFFBA1A1A);

  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.light(
        primary: primary,
        primaryContainer: primaryContainer,
        onPrimary: onPrimary,
        background: background,
        surface: surface,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: onSecondaryContainer,
        outline: outline,
        outlineVariant: outlineVariant,
      ),
      scaffoldBackgroundColor: background,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.manrope(fontSize: 32, fontWeight: FontWeight.w700, color: primaryContainer),
        displayMedium: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w600, color: primaryContainer),
        titleLarge: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w600, color: onSurface),
        bodyLarge: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w400, color: onSurface),
        bodyMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: onSurface),
        bodySmall: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: onSurfaceVariant),
        labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: onSurface, letterSpacing: 0.02),
        labelSmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: onSurfaceVariant),
      ),
      useMaterial3: true,
    );
  }
}
