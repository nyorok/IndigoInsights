import 'package:flutter/material.dart';
import 'package:indigo_insights/theme/app_color_scheme.dart';
import 'package:indigo_insights/theme/app_text_styles.dart';

/// Builds a [ThemeData] from any [AppColorScheme] + [AppTextStyles] pair.
///
/// Usage:
/// ```dart
/// MaterialApp(
///   theme: AppTheme.build(darkScheme, darkStyles),
/// )
/// ```
class AppTheme {
  AppTheme._();

  static ThemeData build(AppColorScheme colors, AppTextStyles styles) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: colors.canvas,

      // ── Material ColorScheme ─────────────────────────────────────────────
      colorScheme: ColorScheme.dark(
        surface: colors.surface,
        primary: colors.primary,
        primaryContainer: colors.primarySurface,
        secondary: colors.primary,
        error: colors.error,
        onSurface: colors.textPrimary,
        onPrimary: colors.textPrimary,
        outline: colors.border,
        outlineVariant: colors.border,
      ),

      // ── Extensions (the source of truth for widgets) ─────────────────────
      extensions: <ThemeExtension<dynamic>>[colors, styles],

      // ── Component themes (sensible defaults, widgets can override) ────────
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.zero,
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: colors.primary,
        unselectedLabelColor: colors.textMuted,
        indicator: const BoxDecoration(),
        dividerColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        labelStyle: styles.tabLabel,
        unselectedLabelStyle: styles.tabLabelInactive,
      ),

      dividerTheme: DividerThemeData(
        color: colors.border,
        thickness: 1,
        space: 1,
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: colors.primary,
        inactiveTrackColor: colors.surfaceRaised,
        thumbColor: colors.textPrimary,
        overlayColor: colors.primarySurface,
        valueIndicatorColor: colors.surface,
        valueIndicatorTextStyle: styles.bodyMd,
      ),

      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(colors.surface),
        dataRowColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return colors.surfaceRaised;
          }
          return Colors.transparent;
        }),
        headingTextStyle: styles.sectionLabel.copyWith(
          color: colors.textMuted,
          letterSpacing: 0.5,
        ),
        dataTextStyle: styles.monoSm.copyWith(color: colors.textSecondary),
        dividerThickness: 0,
        columnSpacing: 16,
        horizontalMargin: 16,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceRaised,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        labelStyle: styles.bodyMd.copyWith(color: colors.textMuted),
        hintStyle: styles.bodyMd.copyWith(color: colors.textMuted),
      ),

      iconTheme: IconThemeData(color: colors.textSecondary, size: 16),

      textSelectionTheme: TextSelectionThemeData(
        selectionColor: colors.primarySurface,
        cursorColor: colors.primary,
      ),

      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(colors.primary),
        trackColor: WidgetStateProperty.all(colors.surfaceRaised),
      ),

      // ── Typography ────────────────────────────────────────────────────────
      textTheme: TextTheme(
        displayLarge: styles.displayValue,
        displayMedium: styles.kpiValue,
        headlineMedium: styles.cardTitle,
        headlineSmall: styles.pageTitle,
        labelSmall: styles.kpiLabel,
        labelMedium: styles.tabLabel,
        bodyMedium: styles.bodyMd,
        bodySmall: styles.bodySm,
      ),
    );
  }
}
