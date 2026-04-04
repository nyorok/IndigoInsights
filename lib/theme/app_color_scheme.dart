import 'package:flutter/material.dart';

/// All semantic color slots for the Indigo Insights design system.
///
/// Registered as a [ThemeExtension] so widgets stay theme-agnostic.
/// Access via [AppColorScheme.of(context)].
///
/// To add a new theme (light, blue, etc.) create a new [AppColorScheme]
/// instance in `lib/theme/schemes/` and pass it to [AppTheme.build].
@immutable
class AppColorScheme extends ThemeExtension<AppColorScheme> {
  const AppColorScheme({
    required this.canvas,
    required this.surface,
    required this.surfaceRaised,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.primary,
    required this.primarySurface,
    required this.primaryBorder,
    required this.success,
    required this.error,
    required this.warning,
    required this.iUsd,
    required this.iBtc,
    required this.iEth,
    required this.iSol,
  });

  // ── Surfaces ──────────────────────────────────────────────────────────────
  /// App background / canvas.
  final Color canvas;

  /// Card / panel background.
  final Color surface;

  /// Elevated chip, unselected tier button.
  final Color surfaceRaised;

  /// Default divider and inactive stroke.
  final Color border;

  // ── Text ──────────────────────────────────────────────────────────────────
  /// Primary text (values, titles).
  final Color textPrimary;

  /// Secondary / muted text (labels).
  final Color textSecondary;

  /// Tertiary / dimmer text (units, hints).
  final Color textMuted;

  // ── Brand accent ──────────────────────────────────────────────────────────
  /// iSOL purple — primary interactive accent.
  final Color primary;

  /// Accent fill at ~13 % opacity (accent panel background).
  final Color primarySurface;

  /// Accent stroke at ~25 % opacity (active tab / selected border).
  final Color primaryBorder;

  // ── Semantic ──────────────────────────────────────────────────────────────
  final Color success;
  final Color error;
  final Color warning;

  // ── iAsset palette ────────────────────────────────────────────────────────
  final Color iUsd;
  final Color iBtc;
  final Color iEth;
  final Color iSol;

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Returns the colour associated with the given iAsset ticker.
  Color forAsset(String asset) => switch (asset) {
        'iUSD' => iUsd,
        'iBTC' => iBtc,
        'iETH' => iEth,
        'iSOL' => iSol,
        _ => primary,
      };

  /// Returns a subtle (13 % opacity) fill colour for the given iAsset.
  Color surfaceForAsset(String asset) => forAsset(asset).withValues(alpha: 0.13);

  /// Returns a divider / stroke colour for the given iAsset (30 % opacity).
  Color borderForAsset(String asset) => forAsset(asset).withValues(alpha: 0.30);

  /// Convenience accessor — throws if extension is not registered.
  static AppColorScheme of(BuildContext context) =>
      Theme.of(context).extension<AppColorScheme>()!;

  // ── ThemeExtension ────────────────────────────────────────────────────────

  @override
  AppColorScheme copyWith({
    Color? canvas,
    Color? surface,
    Color? surfaceRaised,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? primary,
    Color? primarySurface,
    Color? primaryBorder,
    Color? success,
    Color? error,
    Color? warning,
    Color? iUsd,
    Color? iBtc,
    Color? iEth,
    Color? iSol,
  }) =>
      AppColorScheme(
        canvas: canvas ?? this.canvas,
        surface: surface ?? this.surface,
        surfaceRaised: surfaceRaised ?? this.surfaceRaised,
        border: border ?? this.border,
        textPrimary: textPrimary ?? this.textPrimary,
        textSecondary: textSecondary ?? this.textSecondary,
        textMuted: textMuted ?? this.textMuted,
        primary: primary ?? this.primary,
        primarySurface: primarySurface ?? this.primarySurface,
        primaryBorder: primaryBorder ?? this.primaryBorder,
        success: success ?? this.success,
        error: error ?? this.error,
        warning: warning ?? this.warning,
        iUsd: iUsd ?? this.iUsd,
        iBtc: iBtc ?? this.iBtc,
        iEth: iEth ?? this.iEth,
        iSol: iSol ?? this.iSol,
      );

  @override
  AppColorScheme lerp(AppColorScheme? other, double t) {
    if (other == null) return this;
    return AppColorScheme(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primarySurface: Color.lerp(primarySurface, other.primarySurface, t)!,
      primaryBorder: Color.lerp(primaryBorder, other.primaryBorder, t)!,
      success: Color.lerp(success, other.success, t)!,
      error: Color.lerp(error, other.error, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      iUsd: Color.lerp(iUsd, other.iUsd, t)!,
      iBtc: Color.lerp(iBtc, other.iBtc, t)!,
      iEth: Color.lerp(iEth, other.iEth, t)!,
      iSol: Color.lerp(iSol, other.iSol, t)!,
    );
  }
}
