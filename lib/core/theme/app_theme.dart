import 'package:flutter/material.dart';

import 'color_tokens.dart';
import 'spacing_tokens.dart';
import 'text_tokens.dart';

/// Backwards-compatible aliases used by existing feature widgets.
class AppColors {
  static const primary = PremiumColors.lightPrimary;
  static const secondary = Color(0xFF7C3AED);
  static const success = PremiumColors.lightSuccess;
  static const warning = PremiumColors.lightWarning;
  static const danger = PremiumColors.lightError;
  static const ink = PremiumColors.lightTextPrimary;
  static const muted = PremiumColors.lightTextTertiary;
  static const lightCanvas = PremiumColors.lightSurfaceBase;
  static const lightSurface = PremiumColors.lightSurfaceElevated;
  static const darkCanvas = PremiumColors.darkSurfaceBase;
  static const darkSurface = PremiumColors.darkSurfaceElevated;
}

class AppTheme {
  static ThemeData light({String fontFamily = 'Poppins'}) {
    final scheme = ColorScheme.light(
      primary: PremiumColors.lightPrimary,
      onPrimary: Colors.white,
      primaryContainer: PremiumColors.lightPrimarySoft,
      onPrimaryContainer: PremiumColors.lightPrimary,
      secondary: const Color(0xFF6366F1),
      onSecondary: Colors.white,
      secondaryContainer: PremiumColors.lightSurfaceMuted,
      onSecondaryContainer: PremiumColors.lightTextPrimary,
      surface: PremiumColors.lightSurfaceElevated,
      onSurface: PremiumColors.lightTextPrimary,
      surfaceContainerHighest: PremiumColors.lightSurfaceMuted,
      onSurfaceVariant: PremiumColors.lightTextSecondary,
      outline: PremiumColors.lightBorderStrong,
      outlineVariant: PremiumColors.lightBorderSubtle,
      error: PremiumColors.lightError,
      onError: Colors.white,
      errorContainer: PremiumColors.lightErrorSoft,
      onErrorContainer: PremiumColors.lightDueRed,
    );
    return _base(
      scheme,
      PremiumColors.lightSurfaceBase,
      PremiumColors.lightSurfaceElevated,
      fontFamily,
      isDark: false,
    );
  }

  static ThemeData dark({String fontFamily = 'Poppins'}) {
    final scheme = ColorScheme.dark(
      primary: PremiumColors.darkPrimary,
      onPrimary: PremiumColors.darkSurfaceBase,
      primaryContainer: PremiumColors.darkPrimarySoft,
      onPrimaryContainer: PremiumColors.darkTextPrimary,
      secondary: const Color(0xFFA5B4FC),
      onSecondary: PremiumColors.darkSurfaceBase,
      secondaryContainer: PremiumColors.darkSurfaceMuted,
      onSecondaryContainer: PremiumColors.darkTextPrimary,
      surface: PremiumColors.darkSurfaceElevated,
      onSurface: PremiumColors.darkTextPrimary,
      surfaceContainerHighest: PremiumColors.darkSurfaceMuted,
      onSurfaceVariant: PremiumColors.darkTextSecondary,
      outline: PremiumColors.darkBorderStrong,
      outlineVariant: PremiumColors.darkBorderSubtle,
      error: PremiumColors.darkError,
      onError: PremiumColors.darkSurfaceBase,
      errorContainer: PremiumColors.darkErrorSoft,
      onErrorContainer: PremiumColors.darkTextPrimary,
    );
    return _base(
      scheme,
      PremiumColors.darkSurfaceBase,
      PremiumColors.darkSurfaceElevated,
      fontFamily,
      isDark: true,
    );
  }

  static ThemeData _base(
    ColorScheme scheme,
    Color canvas,
    Color surface,
    String fontFamily, {
    required bool isDark,
  }) {
    final textTheme = TextTheme(
      displaySmall: AppTextTokens.screenTitle.copyWith(fontSize: 32),
      headlineSmall: AppTextTokens.screenTitle,
      titleLarge: AppTextTokens.sectionTitle.copyWith(fontSize: 20),
      titleMedium: AppTextTokens.sectionTitle,
      titleSmall: AppTextTokens.cardTitle,
      bodyLarge: AppTextTokens.body.copyWith(fontSize: 16),
      bodyMedium: AppTextTokens.body,
      bodySmall: AppTextTokens.metadata,
      labelLarge: AppTextTokens.bodyMedium,
      labelMedium: AppTextTokens.metadata,
      labelSmall: AppTextTokens.caption,
    ).apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);

    final border = BorderSide(color: scheme.outlineVariant, width: 1);
    final radius = BorderRadius.circular(AppRadii.card);
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadii.field),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: canvas,
      canvasColor: canvas,
      textTheme: textTheme.apply(fontFamily: fontFamily),
      fontFamily: fontFamily,
      visualDensity: VisualDensity.standard,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: canvas,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: scheme.primary.withValues(alpha: 0.08),
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: scheme.onSurface),
        iconTheme: IconThemeData(color: scheme.onSurfaceVariant, size: 22),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: isDark ? 0 : 1,
        shadowColor: scheme.primary.withValues(alpha: isDark ? 0 : 0.06),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: radius, side: border),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: AppSpacing.lg,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? PremiumColors.darkSurfaceMuted
            : PremiumColors.lightSurfaceElevated,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.field),
          borderSide: border,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.field),
          borderSide: border,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.field),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.field),
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.field),
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        elevation: 0,
        height: 72,
        indicatorColor: scheme.primary.withValues(alpha: isDark ? 0.24 : 0.12),
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelMedium),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 22,
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        elevation: isDark ? 0 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.field),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.hero),
          side: border,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(48, 48),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          shape: buttonShape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          side: border,
          shape: buttonShape,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          shape: buttonShape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: buttonShape,
        ),
      ),
      chipTheme: ChipThemeData(
        side: border,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.chip),
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        labelStyle: textTheme.labelMedium,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: isDark ? 0 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.field),
        ),
      ),
    );
  }
}
