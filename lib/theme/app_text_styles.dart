import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// All typographic roles for the Indigo Insights design system.
///
/// Registered as a [ThemeExtension] so fonts can be swapped per theme.
/// Access via [AppTextStyles.of(context)].
@immutable
class AppTextStyles extends ThemeExtension<AppTextStyles> {
  const AppTextStyles({
    required this.displayValue,
    required this.kpiValue,
    required this.cardTitle,
    required this.pageTitle,
    required this.kpiLabel,
    required this.tabLabel,
    required this.tabLabelInactive,
    required this.sectionLabel,
    required this.bodyMd,
    required this.bodySm,
    required this.monoMd,
    required this.monoSm,
  });

  // ── Outfit — values & titles ──────────────────────────────────────────────
  /// 32 / 700 — Hero numbers (display).
  final TextStyle displayValue;

  /// 24 / 700 — KPI strip values.
  final TextStyle kpiValue;

  /// 15 / 600 — Card / section headings.
  final TextStyle cardTitle;

  /// 20 / 600 — Page top-bar title.
  final TextStyle pageTitle;

  // ── Manrope — UI labels ───────────────────────────────────────────────────
  /// 11 / 700 — KPI strip labels (rendered uppercase in widgets).
  final TextStyle kpiLabel;

  /// 13 / 600 — Active tab text.
  final TextStyle tabLabel;

  /// 13 / 500 — Inactive tab text.
  final TextStyle tabLabelInactive;

  /// 11 / 700 — Sub-section headers inside cards.
  final TextStyle sectionLabel;

  /// 12 / 400 — General body copy.
  final TextStyle bodyMd;

  /// 11 / 400 — Supporting / helper text.
  final TextStyle bodySm;

  // ── JetBrains Mono — data ─────────────────────────────────────────────────
  /// 12 / 400 — Addresses, inline data values.
  final TextStyle monoMd;

  /// 11 / 400 — Table cells, small data.
  final TextStyle monoSm;

  // ── Factory — dark (default) ──────────────────────────────────────────────

  /// Creates the default set of text styles for the dark theme.
  /// Pass [color] as the base text colour (usually [AppColorScheme.textPrimary]).
  static AppTextStyles build({Color color = Colors.white}) => AppTextStyles(
        displayValue: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: color,
        ),
        kpiValue: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: color,
        ),
        cardTitle: GoogleFonts.outfit(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: color,
        ),
        pageTitle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: color,
        ),
        kpiLabel: GoogleFonts.manrope(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
        tabLabel: GoogleFonts.manrope(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: color,
        ),
        tabLabelInactive: GoogleFonts.manrope(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: color,
        ),
        sectionLabel: GoogleFonts.manrope(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
        bodyMd: GoogleFonts.manrope(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: color,
        ),
        bodySm: GoogleFonts.manrope(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: color,
        ),
        monoMd: GoogleFonts.jetBrainsMono(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: color,
        ),
        monoSm: GoogleFonts.jetBrainsMono(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: color,
        ),
      );

  /// Convenience accessor — throws if extension is not registered.
  static AppTextStyles of(BuildContext context) =>
      Theme.of(context).extension<AppTextStyles>()!;

  // ── ThemeExtension ────────────────────────────────────────────────────────

  @override
  AppTextStyles copyWith({
    TextStyle? displayValue,
    TextStyle? kpiValue,
    TextStyle? cardTitle,
    TextStyle? pageTitle,
    TextStyle? kpiLabel,
    TextStyle? tabLabel,
    TextStyle? tabLabelInactive,
    TextStyle? sectionLabel,
    TextStyle? bodyMd,
    TextStyle? bodySm,
    TextStyle? monoMd,
    TextStyle? monoSm,
  }) =>
      AppTextStyles(
        displayValue: displayValue ?? this.displayValue,
        kpiValue: kpiValue ?? this.kpiValue,
        cardTitle: cardTitle ?? this.cardTitle,
        pageTitle: pageTitle ?? this.pageTitle,
        kpiLabel: kpiLabel ?? this.kpiLabel,
        tabLabel: tabLabel ?? this.tabLabel,
        tabLabelInactive: tabLabelInactive ?? this.tabLabelInactive,
        sectionLabel: sectionLabel ?? this.sectionLabel,
        bodyMd: bodyMd ?? this.bodyMd,
        bodySm: bodySm ?? this.bodySm,
        monoMd: monoMd ?? this.monoMd,
        monoSm: monoSm ?? this.monoSm,
      );

  @override
  AppTextStyles lerp(AppTextStyles? other, double t) {
    if (other == null) return this;
    return AppTextStyles(
      displayValue: TextStyle.lerp(displayValue, other.displayValue, t)!,
      kpiValue: TextStyle.lerp(kpiValue, other.kpiValue, t)!,
      cardTitle: TextStyle.lerp(cardTitle, other.cardTitle, t)!,
      pageTitle: TextStyle.lerp(pageTitle, other.pageTitle, t)!,
      kpiLabel: TextStyle.lerp(kpiLabel, other.kpiLabel, t)!,
      tabLabel: TextStyle.lerp(tabLabel, other.tabLabel, t)!,
      tabLabelInactive: TextStyle.lerp(tabLabelInactive, other.tabLabelInactive, t)!,
      sectionLabel: TextStyle.lerp(sectionLabel, other.sectionLabel, t)!,
      bodyMd: TextStyle.lerp(bodyMd, other.bodyMd, t)!,
      bodySm: TextStyle.lerp(bodySm, other.bodySm, t)!,
      monoMd: TextStyle.lerp(monoMd, other.monoMd, t)!,
      monoSm: TextStyle.lerp(monoSm, other.monoSm, t)!,
    );
  }
}
