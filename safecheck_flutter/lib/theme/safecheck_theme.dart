import 'package:flutter/material.dart';

/// Shared visual tokens; no safety state or provider behavior lives here.
abstract final class SafeCheckTheme {
  static const mint = Color(0xFF79E5C1);
  static const charcoal = Color(0xFF0B1215);

  static ThemeData build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final seed = ColorScheme.fromSeed(
      seedColor: const Color(0xFF087C66),
      brightness: brightness,
    );
    final colors = dark
        ? seed.copyWith(
            primary: mint,
            onPrimary: const Color(0xFF082D23),
            primaryContainer: const Color(0xFF183E33),
            onPrimaryContainer: const Color(0xFFB3F4DC),
            secondary: const Color(0xFF93CBD0),
            surface: const Color(0xFF111C20),
            surfaceContainerLowest: charcoal,
            surfaceContainerLow: const Color(0xFF142024),
            surfaceContainer: const Color(0xFF17252A),
            surfaceContainerHigh: const Color(0xFF1D2D32),
            surfaceContainerHighest: const Color(0xFF24363B),
            onSurface: const Color(0xFFEDF5F2),
            onSurfaceVariant: const Color(0xFFABBEBD),
            outline: const Color(0xFF637A7C),
            outlineVariant: const Color(0xFF304348),
            error: const Color(0xFFFFA5A5),
            onError: const Color(0xFF4A101A),
            errorContainer: const Color(0xFF43252C),
            onErrorContainer: const Color(0xFFFFDADB),
          )
        : seed;
    final base = ThemeData(useMaterial3: true, colorScheme: colors);
    final rounded = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    );
    return base.copyWith(
      scaffoldBackgroundColor: dark ? charcoal : const Color(0xFFF3F7F5),
      visualDensity: VisualDensity.standard,
      textTheme: base.textTheme.copyWith(
        headlineLarge: base.textTheme.headlineLarge?.copyWith(
          fontSize: 38,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.4,
        ),
        headlineMedium: base.textTheme.headlineMedium?.copyWith(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.9,
        ),
        headlineSmall: base.textTheme.headlineSmall?.copyWith(
          fontSize: 25,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.6,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: base.textTheme.bodyLarge?.copyWith(height: 1.55),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(height: 1.55),
        bodySmall: base.textTheme.bodySmall?.copyWith(
          height: 1.5,
          color: colors.onSurfaceVariant,
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: dark ? charcoal : const Color(0xFFF3F7F5),
        foregroundColor: colors.onSurface,
        centerTitle: false,
        toolbarHeight: 76,
        titleTextStyle: TextStyle(
          color: colors.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 54),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          shape: rounded,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 50),
          shape: rounded,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          side: BorderSide(color: colors.outline),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: colors.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.7)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colors.outlineVariant.withValues(alpha: 0.7),
        space: 28,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 76,
        elevation: 0,
        backgroundColor: colors.surface,
        indicatorColor: colors.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? colors.primary
                : colors.onSurfaceVariant,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colors.surface,
        indicatorColor: colors.primaryContainer,
        selectedIconTheme: IconThemeData(color: colors.primary),
        selectedLabelTextStyle: TextStyle(
          color: colors.primary,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelTextStyle: TextStyle(color: colors.onSurfaceVariant),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: colors.outlineVariant),
        selectedColor: colors.primaryContainer,
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: rounded,
      ),
    );
  }
}
