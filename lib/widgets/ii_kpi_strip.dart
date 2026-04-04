import 'package:flutter/material.dart';
import 'package:indigo_insights/theme/app_color_scheme.dart';
import 'package:indigo_insights/theme/app_text_styles.dart';

/// A single cell in the [IIKpiStrip].
class IIKpiCell {
  const IIKpiCell({
    required this.label,
    required this.value,
    this.unit,
    this.valueColor,
    this.subtitle,
  });

  final String label;
  final String value;

  /// Optional unit shown after the value (e.g. "ADA", "INDY").
  final String? unit;

  /// Override colour for the value text (e.g. success/error for deltas).
  final Color? valueColor;

  /// Optional small subtitle below the value.
  final String? subtitle;
}

/// KPI metrics strip — grey card style, full width.
///
/// On desktop: cells are in a horizontal row separated by vertical dividers.
/// On mobile: cells stack vertically separated by horizontal dividers.
class IIKpiStrip extends StatelessWidget {
  const IIKpiStrip({super.key, required this.cells});

  final List<IIKpiCell> cells;

  static const _kDesktopBreakpoint = 700.0;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final styles = AppTextStyles.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= _kDesktopBreakpoint;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: isDesktop
          ? IntrinsicHeight(
              child: Row(
                children: [
                  for (int i = 0; i < cells.length; i++) ...[
                    if (i > 0) _VerticalDivider(colors: colors),
                    Expanded(child: _Cell(cell: cells[i], colors: colors, styles: styles)),
                  ],
                ],
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < cells.length; i++) ...[
                  if (i > 0) _HorizontalDivider(colors: colors),
                  _Cell(cell: cells[i], colors: colors, styles: styles),
                ],
              ],
            ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider({required this.colors});
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: VerticalDivider(
        color: colors.border,
        width: 1,
        thickness: 1,
      ),
    );
  }
}

class _HorizontalDivider extends StatelessWidget {
  const _HorizontalDivider({required this.colors});
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(
        color: colors.border,
        height: 1,
        thickness: 1,
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.cell,
    required this.colors,
    required this.styles,
  });

  final IIKpiCell cell;
  final AppColorScheme colors;
  final AppTextStyles styles;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            cell.label.toUpperCase(),
            style: styles.kpiLabel.copyWith(color: colors.textMuted),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  cell.value,
                  style: styles.kpiValue.copyWith(
                    color: cell.valueColor ?? colors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (cell.unit != null) ...[
                const SizedBox(width: 4),
                Text(
                  cell.unit!,
                  style: styles.bodySm.copyWith(color: colors.textMuted),
                ),
              ],
            ],
          ),
          if (cell.subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              cell.subtitle!,
              style: styles.bodySm.copyWith(color: colors.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}
