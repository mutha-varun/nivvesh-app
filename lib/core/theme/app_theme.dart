import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nivvesh/core/theme/app_colors.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData darkTheme  = _build(AppColors.dark,  Brightness.dark);
  static final ThemeData lightTheme = _build(AppColors.light, Brightness.light);

  static ThemeData _build(AppColorsBase c, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: c.background,
      colorScheme: isDark
          ? ColorScheme.dark(
              primary: c.gold,
              onPrimary: Colors.black,
              secondary: c.accent,
              onSecondary: c.accentText,
              surface: c.surface,
              onSurface: c.primaryText,
              error: c.error,
              outline: c.border,
            )
          : ColorScheme.light(
              primary: c.gold,
              onPrimary: c.accentText,
              secondary: c.accent,
              onSecondary: c.accentText,
              surface: c.surface,
              onSurface: c.primaryText,
              error: c.error,
              outline: c.border,
            ),
      textTheme: _buildTextTheme(c),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: c.primaryText,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? c.cardSurface : c.surfaceContainerLow,
        selectedColor: c.gold.withValues(alpha: isDark ? 0.18 : 0.15),
        side: BorderSide(color: isDark ? c.gold.withValues(alpha: 0.22) : c.outlineVariant),
        labelStyle: GoogleFonts.inter(
          color: c.primaryText,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: GoogleFonts.inter(
          color: c.gold,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.gold,
          foregroundColor: isDark ? Colors.black : c.accentText,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.primaryText,
          side: BorderSide(color: isDark ? c.gold.withValues(alpha: 0.35) : c.outlineVariant),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      dividerTheme: DividerThemeData(color: c.border, thickness: 1),
    );
  }

  static TextTheme _buildTextTheme(AppColorsBase c) {
    final base = GoogleFonts.interTextTheme();
    return base.copyWith(
      displaySmall: base.displaySmall?.copyWith(
        color: c.primaryText,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        color: c.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 21,
        letterSpacing: -0.5,
      ),
      titleLarge: base.titleLarge?.copyWith(
        color: c.primaryText,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: base.bodyLarge?.copyWith(color: c.primaryText),
      bodyMedium: base.bodyMedium?.copyWith(color: c.secondaryText, height: 1.5),
      labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 13),
      labelMedium: base.labelMedium?.copyWith(color: c.secondaryText, fontSize: 12),
    );
  }
}

/// Static decoration helpers. Dark-only for now; extend when light theme is polished.
class AppDecorations {
  AppDecorations._();

  /// Bottom sheet container with gold border.
  static BoxDecoration luxBottomSheet({double radius = 20}) => BoxDecoration(
        color: AppColors.dark.cardSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
        border: Border.all(color: AppColors.dark.gold.withValues(alpha: 0.20)),
      );

  /// Card used in period-summary rows.
  static final BoxDecoration luxCard = BoxDecoration(
    color: AppColors.dark.cardSurface,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
  );

  /// 40×4 drag handle pill inside bottom sheets.
  static final BoxDecoration dragHandle = BoxDecoration(
    color: Colors.white.withValues(alpha: 0.18),
    borderRadius: BorderRadius.circular(2),
  );
}
