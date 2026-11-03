import 'package:flutter/material.dart';
import 'package:maxtune_player/shared/themes/app_fonts.dart';

class AppThemes {
  AppThemes._();

  // Primary brand accent (consistent across themes)
  static const Color primary = Color.fromARGB(255, 211, 13, 105);
  static const Color primaryHover = Color.fromARGB(255, 185, 10, 90);
  static const Color onPrimary = Colors.white;

  // Light Palette
  static const Color lightBackground = Color(0xFFF7F8FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceContainer = Color(0xFFF0F2F5);
  static const Color lightText = Colors.black;
  static const Color lightSecondaryText = Color(0xFF737B89);
  static const Color lightBorder = Color(0xFFE2E5EC);

  // Dark Palette
  static const Color darkBackground = Color(0xFF17191E);
  static const Color darkSurface = Color(0xFF20232A);
  static const Color darkSurfaceContainer = Color(0xFF282C35);
  static const Color darkText = Colors.white;
  static const Color darkSecondaryText = Color(0xFF9BA2AF);
  static const Color darkBorder = Color(0xFF323640);

  static ThemeData get light {
    return _buildTheme(
      brightness: Brightness.light,
      background: lightBackground,
      surface: lightSurface,
      surfaceContainer: lightSurfaceContainer,
      text: lightText,
      secondaryText: lightSecondaryText,
      border: lightBorder,
    );
  }

  static ThemeData get dark {
    return _buildTheme(
      brightness: Brightness.dark,
      background: darkBackground,
      surface: darkSurface,
      surfaceContainer: darkSurfaceContainer,
      text: darkText,
      secondaryText: darkSecondaryText,
      border: darkBorder,
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color surfaceContainer,
    required Color text,
    required Color secondaryText,
    required Color border,
  }) {
    final isDark = brightness == Brightness.dark;

    // Custom ColorScheme without seed generation
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: isDark
          ? const Color(0xFF4A1535)
          : const Color(0xFFFCE8F3),
      onPrimaryContainer: isDark
          ? const Color(0xFFFFD1EC)
          : const Color(0xFF80053D),
      secondary: secondaryText,
      onSecondary: background,
      surface: surface,
      onSurface: text,
      surfaceContainerHighest: surfaceContainer,
      error: const Color(0xFFD93838),
      onError: Colors.white,
      outline: border,
      outlineVariant: border,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      fontFamily: AppFonts.asapSharp,

      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: text,
          fontFamily: AppFonts.asapSharp,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),

      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Tighter Fluent-style radius
          side: BorderSide(color: border, width: 1),
        ),
      ),

      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),

      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: text,
          fontSize: 28,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: TextStyle(
          color: text,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: text,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: text,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: text, fontSize: 14),
        bodyMedium: TextStyle(color: text, fontSize: 13),
        bodySmall: TextStyle(color: text, fontSize: 12),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6), // Compact Fluent rounding
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFFD93838), width: 1),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          textStyle: TextStyle(fontSize: 13),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text,
          backgroundColor: surface,
          side: BorderSide(color: border),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: text,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),

      iconTheme: IconThemeData(color: isDark ? darkText : lightText, size: 18),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: .circular(2)),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: surface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(color: border),
        ),
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? darkSurfaceContainer : lightText,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: border),
        ),
        textStyle: TextStyle(
          color: isDark ? darkText : Colors.white,
          fontSize: 11,
        ),
      ),
    );
  }
}
