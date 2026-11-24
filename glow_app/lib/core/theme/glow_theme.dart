import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum GlowThemeMode { femalePink, maleBlue }

class GlowPalette {
  final Color background;
  final Color surface;
  final Color surfaceSecondary;
  final Color primaryDark;
  final Color primaryText;
  final Color secondaryText;
  final Color mutedText;
  final Color accent;
  final Color accentLight;
  final Color accentDark;
  final Color border;
  final Color chipBackground;
  final Color chipActive;
  final Color success;
  final Color warning;
  final Color error;
  final Color scoreRingTrack;
  final List<Color> gradientWarm;

  const GlowPalette({
    required this.background,
    required this.surface,
    required this.surfaceSecondary,
    required this.primaryDark,
    required this.primaryText,
    required this.secondaryText,
    required this.mutedText,
    required this.accent,
    required this.accentLight,
    required this.accentDark,
    required this.border,
    required this.chipBackground,
    required this.chipActive,
    required this.success,
    required this.warning,
    required this.error,
    required this.scoreRingTrack,
    required this.gradientWarm,
  });

  /// Female Theme: Inspired directly by reference Pinterest "Beauty&Care"
  /// Warm ivory/linen background, blush rose accents, dark espresso pill buttons.
  static const female = GlowPalette(
    background: Color(0xFFFAF6F0), // warm ivory/linen
    surface: Color(0xFFFFFFFF),    // crisp white
    surfaceSecondary: Color(0xFFF5EFEB), // soft tinted card
    primaryDark: Color(0xFF26201E), // dark espresso charcoal pill
    primaryText: Color(0xFF1E1A19),
    secondaryText: Color(0xFF8D837D), // elegant warm gray
    mutedText: Color(0xFFB8ADA6),
    accent: Color(0xFFC58B7D),       // dusty blush terracotta
    accentLight: Color(0xFFF5EBE6),  // soft blush peach icon circle
    accentDark: Color(0xFFA86F62),
    border: Color(0xFFEFE6DF),       // soft border
    chipBackground: Color(0xFFF3ECE6),
    chipActive: Color(0xFF26201E),
    success: Color(0xFF4E8D7C),      // sage green
    warning: Color(0xFFD99B4E),      // warm honey
    error: Color(0xFFC95C5C),        // soft berry red
    scoreRingTrack: Color(0xFFEDE4DC),
    gradientWarm: [
      Color(0xFFE6C5B8),
      Color(0xFFDDB8A9),
    ],
  );

  /// Male Theme: Clean, modern slate blue / sky aesthetic
  /// Cool crisp white background, calm navy/blue accents, deep navy pill buttons.
  static const male = GlowPalette(
    background: Color(0xFFF4F7F9), // cool pristine white/gray
    surface: Color(0xFFFFFFFF),
    surfaceSecondary: Color(0xFFEBF1F5),
    primaryDark: Color(0xFF1A222E), // deep navy charcoal pill
    primaryText: Color(0xFF141C24),
    secondaryText: Color(0xFF75828D),
    mutedText: Color(0xFFA3AFB8),
    accent: Color(0xFF4A7C9D),       // calm slate sky blue
    accentLight: Color(0xFFE6EFF5),  // cool ice blue icon circle
    accentDark: Color(0xFF345F7C),
    border: Color(0xFFDFE7ED),
    chipBackground: Color(0xFFE9F0F4),
    chipActive: Color(0xFF1A222E),
    success: Color(0xFF3B8A74),
    warning: Color(0xFFC88C3E),
    error: Color(0xFFC04B4B),
    scoreRingTrack: Color(0xFFDEE7EC),
    gradientWarm: [
      Color(0xFF7BA2BC),
      Color(0xFF5C8DAA),
    ],
  );
}

class GlowTheme {
  static ThemeData buildTheme(GlowThemeMode mode) {
    final palette = mode == GlowThemeMode.femalePink
        ? GlowPalette.female
        : GlowPalette.male;

    final baseTextTheme = GoogleFonts.interTextTheme();
    final serifFont = GoogleFonts.playfairDisplay;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: palette.background,
      primaryColor: palette.primaryDark,
      cardColor: palette.surface,
      dividerColor: palette.border,
      colorScheme: ColorScheme.light(
        primary: palette.primaryDark,
        secondary: palette.accent,
        surface: palette.surface,
        background: palette.background,
        error: palette.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: palette.primaryText,
        onBackground: palette.primaryText,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: serifFont(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: palette.primaryText,
          letterSpacing: -0.5,
        ),
        displayMedium: serifFont(
          fontSize: 26,
          fontWeight: FontWeight.w600,
          color: palette.primaryText,
          letterSpacing: -0.3,
        ),
        headlineLarge: serifFont(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: palette.primaryText,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: palette.primaryText,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: palette.primaryText,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: palette.primaryText,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: palette.primaryText,
          height: 1.45,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: palette.secondaryText,
          height: 1.4,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: palette.primaryText, size: 20),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: palette.primaryText,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primaryDark,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // Pill button from reference
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: palette.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: palette.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: palette.accent, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: palette.mutedText,
        ),
      ),
    );
  }
}
