import 'package:flutter/material.dart';
import 'package:indigo_insights/theme/app_color_scheme.dart';
import 'package:indigo_insights/theme/app_text_styles.dart';

/// Badge variants used across the app.
enum IIBadgeVariant { live, success, warning, error, neutral }

/// Small status badge (rounded pill).
///
/// For the top-bar "Live" badge use [IIBadgeVariant.live].
/// For risk / status chips use the appropriate semantic variant.
class IIBadge extends StatelessWidget {
  const IIBadge({
    super.key,
    required this.label,
    this.variant = IIBadgeVariant.neutral,
  });

  final String label;
  final IIBadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final styles = AppTextStyles.of(context);

    final (bg, fg) = _colors(variant, colors);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: styles.bodySm.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static (Color bg, Color fg) _colors(
    IIBadgeVariant v,
    AppColorScheme c,
  ) =>
      switch (v) {
        IIBadgeVariant.live => (
          c.success.withValues(alpha: 0.15),
          c.success,
        ),
        IIBadgeVariant.success => (
          c.success.withValues(alpha: 0.15),
          c.success,
        ),
        IIBadgeVariant.warning => (
          c.warning.withValues(alpha: 0.15),
          c.warning,
        ),
        IIBadgeVariant.error => (
          c.error.withValues(alpha: 0.15),
          c.error,
        ),
        IIBadgeVariant.neutral => (
          c.surfaceRaised,
          c.textSecondary,
        ),
      };
}
