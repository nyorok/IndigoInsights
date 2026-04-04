import 'package:flutter/material.dart';
import 'package:indigo_insights/theme/app_color_scheme.dart';
import 'package:indigo_insights/theme/app_text_styles.dart';

/// Muted uppercase section header inside a card.
class IISectionHeader extends StatelessWidget {
  const IISectionHeader(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final styles = AppTextStyles.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Text(
        label.toUpperCase(),
        style: styles.sectionLabel.copyWith(
          color: colors.textMuted,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
