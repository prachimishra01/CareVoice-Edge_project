import 'package:flutter/material.dart';

/// Centralized color palette mirroring Tailwind CSS slate and vibrant accent scale.
class AppColors {
  AppColors._();

  // Slate Palette
  static const slate950 = Color(0xFF020617);
  static const slate900 = Color(0xFF0F172A);
  static const slate800 = Color(0xFF1E293B);
  static const slate700 = Color(0xFF334155);
  static const slate600 = Color(0xFF475569);
  static const slate500 = Color(0xFF64748B);
  static const slate400 = Color(0xFF94A3B8);
  static const slate300 = Color(0xFFCBD5E1);
  static const slate200 = Color(0xFFE2E8F0);
  static const slate100 = Color(0xFFF1F5F9);
  static const slate50 = Color(0xFFF8FAFC);

  // Accent Colors
  static const indigo600 = Color(0xFF4F46E5);
  static const indigo500 = Color(0xFF6366F1);
  static const indigo400 = Color(0xFF818CF8);
  static const indigo300 = Color(0xFFA5B4FC);

  static const purple600 = Color(0xFF9333EA);
  static const purple500 = Color(0xFFA855F7);

  static const emerald500 = Color(0xFF10B981);
  static const emerald400 = Color(0xFF34D399);
  static const emerald300 = Color(0xFF6EE7B7);

  static const rose600 = Color(0xFFE11D48);
  static const rose500 = Color(0xFFF43F5E);
  static const rose400 = Color(0xFFFB7185);
  static const rose300 = Color(0xFFFDA4AF);

  static const amber500 = Color(0xFFF59E0B);
  static const amber400 = Color(0xFFFBBF24);
  static const amber300 = Color(0xFFFCD34D);

  // Light Mode Semantic Colors (Optimized for maximum contrast & crisp readability)
  static const bgLight = Color(0xFFF8FAFC);
  static const cardLight = Colors.white;
  static const subtleLight = Color(0xFFF1F5F9);
  static const textPrimaryLight = Color(0xFF0F172A); // Slate 900
  static const textSecondaryLight = Color(0xFF334155); // Slate 700 for high-contrast secondary text
  static const borderLight = Color(0xFFE2E8F0);

  // Dark Mode Semantic Colors
  static const bgDark = Color(0xFF020617);
  static const cardDark = Color(0xFF0F172A);
  static const subtleDark = Color(0xFF1E293B);
  static const textPrimaryDark = Color(0xFFF8FAFC);
  static const textSecondaryDark = Color(0xFF94A3B8);
  static const borderDark = Color(0xFF334155);

  // Standard legacy references maintained for backward compatibility
  static const textPrimary = textPrimaryLight;
  static const textSecondary = textSecondaryLight;

  // Gradients
  static const gradientPrimary = LinearGradient(
    colors: [indigo500, purple600],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const softGradientLight = LinearGradient(
    colors: [Color(0xFFEEF2FF), Color(0xFFF5F3FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const softGradientDark = LinearGradient(
    colors: [slate900, slate800],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// Comprehensive Material 3 ThemeData definitions for Light & Dark modes.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    final textTheme = _buildTextTheme(base.textTheme, AppColors.textPrimaryLight, AppColors.textSecondaryLight);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bgLight,
      colorScheme: ColorScheme.light(
        primary: AppColors.indigo500,
        onPrimary: Colors.white,
        primaryContainer: const Color(0xFFEEF2FF),
        onPrimaryContainer: AppColors.indigo600,
        secondary: AppColors.purple600,
        onSecondary: Colors.white,
        secondaryContainer: const Color(0xFFF5F3FF),
        onSecondaryContainer: AppColors.purple600,
        surface: AppColors.cardLight,
        onSurface: AppColors.textPrimaryLight,
        onSurfaceVariant: AppColors.textSecondaryLight,
        error: AppColors.rose500,
        onError: Colors.white,
        outline: AppColors.borderLight,
        surfaceContainerHighest: AppColors.subtleLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textPrimaryLight),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimaryLight,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardColor: AppColors.cardLight,
      cardTheme: CardThemeData(
        color: AppColors.cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderLight),
        ),
      ),
      dividerColor: AppColors.borderLight,
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.indigo500,
        unselectedItemColor: AppColors.slate600,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.subtleLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.indigo500, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.rose500),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 13, fontWeight: FontWeight.w500),
        hintStyle: const TextStyle(color: AppColors.slate500, fontSize: 13),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.cardLight,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.borderLight),
        ),
        titleTextStyle: const TextStyle(
          color: AppColors.textPrimaryLight,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: const TextStyle(
          color: AppColors.textSecondaryLight,
          fontSize: 14,
        ),
      ),
      textTheme: textTheme,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.indigo500,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.slate200,
          disabledForegroundColor: AppColors.slate600,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.indigo500,
          disabledForegroundColor: AppColors.slate500,
          side: const BorderSide(color: AppColors.borderLight),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        ),
      ),
    );
  }

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = _buildTextTheme(base.textTheme, AppColors.textPrimaryDark, AppColors.textSecondaryDark);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bgDark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.indigo500,
        onPrimary: Colors.white,
        primaryContainer: AppColors.slate800,
        onPrimaryContainer: AppColors.indigo300,
        secondary: AppColors.purple600,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.slate800,
        onSecondaryContainer: AppColors.purple500,
        surface: AppColors.cardDark,
        onSurface: AppColors.textPrimaryDark,
        onSurfaceVariant: AppColors.textSecondaryDark,
        error: AppColors.rose500,
        onError: Colors.white,
        outline: AppColors.borderDark,
        surfaceContainerHighest: AppColors.subtleDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textPrimaryDark),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimaryDark,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardColor: AppColors.cardDark,
      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderDark),
        ),
      ),
      dividerColor: AppColors.borderDark,
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardDark,
        selectedItemColor: AppColors.indigo400,
        unselectedItemColor: AppColors.slate400,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.subtleDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.indigo500, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.rose500),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 13),
        hintStyle: const TextStyle(color: AppColors.slate500, fontSize: 13),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.cardDark,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.borderDark),
        ),
        titleTextStyle: const TextStyle(
          color: AppColors.textPrimaryDark,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: const TextStyle(
          color: AppColors.textSecondaryDark,
          fontSize: 14,
        ),
      ),
      textTheme: textTheme,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.indigo500,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.slate800,
          disabledForegroundColor: AppColors.slate400,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.indigo400,
          disabledForegroundColor: AppColors.slate500,
          side: const BorderSide(color: AppColors.borderDark),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme(TextTheme base, Color primaryColor, Color secondaryColor) {
    return base.copyWith(
      headlineLarge: base.headlineLarge?.copyWith(color: primaryColor, fontWeight: FontWeight.bold),
      headlineMedium: base.headlineMedium?.copyWith(color: primaryColor, fontWeight: FontWeight.bold),
      titleLarge: base.titleLarge?.copyWith(color: primaryColor, fontWeight: FontWeight.bold),
      titleMedium: base.titleMedium?.copyWith(color: primaryColor, fontWeight: FontWeight.w600),
      titleSmall: base.titleSmall?.copyWith(color: secondaryColor, fontWeight: FontWeight.w500),
      bodyLarge: base.bodyLarge?.copyWith(color: primaryColor),
      bodyMedium: base.bodyMedium?.copyWith(color: primaryColor),
      bodySmall: base.bodySmall?.copyWith(color: secondaryColor),
      labelLarge: base.labelLarge?.copyWith(color: primaryColor, fontWeight: FontWeight.bold),
      labelMedium: base.labelMedium?.copyWith(color: secondaryColor),
      labelSmall: base.labelSmall?.copyWith(color: secondaryColor),
    );
  }
}

/// Convenience BuildContext extension for rapid theme-aware color lookup.
extension ThemeContextX on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get scaffoldBg => isDark ? AppColors.bgDark : AppColors.bgLight;
  Color get surfaceColor => isDark ? AppColors.cardDark : AppColors.cardLight;
  Color get subtleBg => isDark ? AppColors.subtleDark : AppColors.subtleLight;
  Color get textPrimaryColor => isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
  Color get textSecondaryColor => isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
  Color get borderColor => isDark ? AppColors.borderDark : AppColors.borderLight;
}
