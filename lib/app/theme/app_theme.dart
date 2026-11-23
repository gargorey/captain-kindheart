import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static const String fontFamily = 'Cairo';

  static TextStyle _w(double size, FontWeight weight, {Color color = AppColors.ink}) => TextStyle(
    fontFamily: fontFamily,
    fontSize: size,
    fontWeight: weight,
    // Cairo ships as a variable font, so drive the weight axis explicitly.
    fontVariations: [FontVariation('wght', weight.value.toDouble())],
    color: color,
    height: 1.5,
  );

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.teal,
      primary: AppColors.teal,
      secondary: AppColors.coral,
      tertiary: AppColors.yellow,
      surface: AppColors.cream,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: AppColors.cream,
      textTheme: TextTheme(
        displaySmall: _w(30, FontWeight.w800),
        headlineSmall: _w(24, FontWeight.w800),
        titleLarge: _w(20, FontWeight.w700),
        titleMedium: _w(17, FontWeight.w700),
        bodyLarge: _w(17, FontWeight.w500),
        bodyMedium: _w(15, FontWeight.w500),
        bodySmall: _w(13, FontWeight.w500, color: AppColors.inkSoft),
        labelLarge: _w(16, FontWeight.w700),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.ink,
        titleTextStyle: _w(20, FontWeight.w800),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 56),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          textStyle: _w(17, FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 56),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          side: const BorderSide(color: AppColors.teal, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          textStyle: _w(16, FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.teal, width: 2),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        labelStyle: _w(15, FontWeight.w700),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(Colors.white),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? AppColors.teal : const Color(0xFFCFD8DC),
        ),
      ),
    );
  }
}
