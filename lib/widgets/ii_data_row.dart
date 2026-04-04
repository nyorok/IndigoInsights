import 'package:flutter/material.dart';
import 'package:indigo_insights/theme/app_color_scheme.dart';
import 'package:indigo_insights/theme/app_text_styles.dart';

/// A label → value row used inside info cards.
///
/// [label] is shown in [AppTextStyles.bodyMd] muted colour.
/// [value] defaults to [AppTextStyles.monoMd] primary colour but can be
/// overridden via [valueStyle] and [valueColor].
class IIDataRow extends StatelessWidget {
  const IIDataRow({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.valueColor,
    this.valueStyle,
    this.padding = const EdgeInsets.symmetric(vertical: 5),
    this.divider = false,
  });

  final String label;
  final String value;

  /// Optional unit appended after the value in muted colour.
  final String? unit;

  /// Override colour for the value text.
  final Color? valueColor;

  /// Override the entire value [TextStyle].
  final TextStyle? valueStyle;

  final EdgeInsetsGeometry padding;

  /// If true, adds a thin divider below this row.
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final styles = AppTextStyles.of(context);

    final resolvedValueStyle = (valueStyle ?? styles.monoMd).copyWith(
      color: valueColor ?? colors.textPrimary,
    );

    final Widget row = Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: styles.bodyMd.copyWith(color: colors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: resolvedValueStyle),
              if (unit != null) ...[
                const SizedBox(width: 3),
                Text(
                  unit!,
                  style: styles.bodySm.copyWith(color: colors.textMuted),
                ),
              ],
            ],
          ),
        ],
      ),
    );

    if (divider) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          row,
          Divider(color: colors.border, height: 1, thickness: 1),
        ],
      );
    }
    return row;
  }
}
