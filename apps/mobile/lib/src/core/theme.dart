import 'package:flutter/material.dart';

class RouteviaColors {
  // Brand
  static const navy = Color(0xFF060D1A);
  static const navyDark = Color(0xFF030810);
  static const navyMid = Color(0xFF0B1F3A);
  static const navyLight = Color(0xFF133E75);
  static const teal = Color(0xFF00C2A8);
  static const tealLight = Color(0xFF19E4CC);
  static const tealDark = Color(0xFF009E88);
  static const amber = Color(0xFFFFB703);
  static const rose = Color(0xFFFF6B6B);

  // Light theme surface
  static const background = Color(0xFFF5F7FA);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF0F4F8);
  static const border = Color(0xFFE2E8F0);
  static const borderLight = Color(0xFFF1F5F9);

  // Text
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF475569);
  static const textTertiary = Color(0xFF94A3B8);

  // Semantic
  static const error = Color(0xFFEF4444);
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);

  // Gradient presets
  static const heroGradient = LinearGradient(
    colors: [Color(0xFF060D1A), Color(0xFF0B1F3A), Color(0xFF133E75)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const tealGradient = LinearGradient(
    colors: [Color(0xFF00C2A8), Color(0xFF0B9E8A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Legacy compat
  static const primary = navyMid;
  static const accent = teal;
  static const sunset = amber;
  static const background_ = background;
  static const card = surface;
}

ThemeData buildRouteviaTheme() {
  const scheme = ColorScheme(
    brightness: Brightness.light,
    primary: RouteviaColors.navyMid,
    onPrimary: Colors.white,
    secondary: RouteviaColors.teal,
    onSecondary: Colors.white,
    tertiary: RouteviaColors.amber,
    onTertiary: RouteviaColors.navyMid,
    error: RouteviaColors.error,
    onError: Colors.white,
    surface: RouteviaColors.surface,
    onSurface: RouteviaColors.textPrimary,
    surfaceContainerHighest: RouteviaColors.surfaceVariant,
    outline: RouteviaColors.border,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: RouteviaColors.background,

    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: RouteviaColors.textPrimary,
        fontWeight: FontWeight.w900,
        fontSize: 36,
        letterSpacing: -1.0,
        height: 1.1,
      ),
      displayMedium: TextStyle(
        color: RouteviaColors.textPrimary,
        fontWeight: FontWeight.w800,
        fontSize: 28,
        letterSpacing: -0.5,
        height: 1.15,
      ),
      headlineLarge: TextStyle(
        color: RouteviaColors.textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 22,
        letterSpacing: -0.3,
      ),
      headlineMedium: TextStyle(
        color: RouteviaColors.textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 18,
        letterSpacing: -0.2,
      ),
      titleLarge: TextStyle(
        color: RouteviaColors.textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 16,
      ),
      titleMedium: TextStyle(
        color: RouteviaColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      titleSmall: TextStyle(
        color: RouteviaColors.textSecondary,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      bodyLarge: TextStyle(
        color: RouteviaColors.textPrimary,
        fontSize: 15,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        color: RouteviaColors.textPrimary,
        fontSize: 14,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        color: RouteviaColors.textSecondary,
        fontSize: 12,
        height: 1.4,
      ),
      labelLarge: TextStyle(
        color: RouteviaColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 14,
        letterSpacing: 0.1,
      ),
      labelMedium: TextStyle(
        color: RouteviaColors.textSecondary,
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
      labelSmall: TextStyle(
        color: RouteviaColors.textTertiary,
        fontWeight: FontWeight.w500,
        fontSize: 11,
        letterSpacing: 0.2,
      ),
    ),

    appBarTheme: const AppBarTheme(
      centerTitle: false,
      backgroundColor: RouteviaColors.surface,
      surfaceTintColor: Colors.transparent,
      foregroundColor: RouteviaColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: Color(0x14000000),
      titleTextStyle: TextStyle(
        color: RouteviaColors.textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 18,
        letterSpacing: -0.2,
      ),
    ),

    cardTheme: CardThemeData(
      color: RouteviaColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: RouteviaColors.border, width: 1),
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: RouteviaColors.navyMid,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        elevation: 0,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: RouteviaColors.navyMid,
        side: const BorderSide(color: RouteviaColors.border, width: 1.2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: RouteviaColors.teal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),

    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      selectedColor: RouteviaColors.navyMid,
      backgroundColor: RouteviaColors.surfaceVariant,
      side: BorderSide.none,
      labelStyle: const TextStyle(
        color: RouteviaColors.textPrimary,
        fontWeight: FontWeight.w500,
        fontSize: 13,
      ),
      secondaryLabelStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),

    inputDecorationTheme: InputDecorationTheme(
      fillColor: RouteviaColors.surfaceVariant,
      filled: true,
      hintStyle: const TextStyle(
        color: RouteviaColors.textTertiary,
        fontSize: 14,
      ),
      labelStyle: const TextStyle(
        color: RouteviaColors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: RouteviaColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: RouteviaColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: RouteviaColors.teal, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: RouteviaColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: RouteviaColors.surface,
      modalBackgroundColor: RouteviaColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      showDragHandle: true,
      dragHandleColor: RouteviaColors.border,
      dragHandleSize: Size(40, 4),
    ),

    dividerTheme: const DividerThemeData(
      color: RouteviaColors.borderLight,
      thickness: 1,
      space: 0,
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        return RouteviaColors.textTertiary;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return RouteviaColors.teal;
        return RouteviaColors.surfaceVariant;
      }),
    ),

    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      minLeadingWidth: 24,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    ),
  );
}
