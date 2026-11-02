import 'package:flutter/material.dart';

class AppThemes {
  AppThemes._();

  static const Color primary = Color(0xFF356AE6);

  static const Color lightBackground = Color(0xFFF7F8FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF20242C);
  static const Color lightSecondaryText = Color(0xFF737B89);
  static const Color lightBorder = Color(0xFFE7E9EE);

  static const Color darkBackground = Color(0xFF17191E);
  static const Color darkSurface = Color(0xFF20232A);
  static const Color darkText = Color(0xFFF1F2F5);
  static const Color darkSecondaryText = Color(0xFF9BA2AF);
  static const Color darkBorder = Color(0xFF343842);

  static ThemeData get light {
    return _buildTheme(
      brightness: Brightness.light,
      background: lightBackground,
      surface: lightSurface,
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
      text: darkText,
      secondaryText: darkSecondaryText,
      border: darkBorder,
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color text,
    required Color secondaryText,
    required Color border,
  }) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
      surface: surface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      fontFamily: 'AsapSharp',

      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),

      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: border),
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
        bodyMedium: TextStyle(color: secondaryText, fontSize: 13),
        bodySmall: TextStyle(color: secondaryText, fontSize: 12),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text,
          side: BorderSide(color: border),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        ),
      ),

      iconTheme: IconThemeData(
        color: isDark ? darkSecondaryText : lightSecondaryText,
        size: 20,
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? darkSurface : lightText,
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}
