import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:indigo_insights/theme/app_color_scheme.dart';
import 'package:indigo_insights/theme/app_text_styles.dart';

/// A single bar data entry for [IIBarChart].
class IIBarData {
  const IIBarData({required this.label, required this.value});

  final String label;
  final double value;
}

/// Design-system bar chart built on [BarChart] (fl_chart).
///
/// All styling comes from [AppColorScheme] — no hard-coded colours.
/// Pass [barColor] to override the default ([AppColorScheme.primary]).
class IIBarChart extends StatelessWidget {
  const IIBarChart({
    super.key,
    required this.data,
    this.barColor,
    this.showLabels = true,
    this.maxY,
    this.height = 200,
  });

  final List<IIBarData> data;

  /// Colour of all bars.  Defaults to [AppColorScheme.primary].
  final Color? barColor;

  final bool showLabels;
  final double? maxY;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final styles = AppTextStyles.of(context);
    final color = barColor ?? colors.primary;

    final maxValue = maxY ??
        (data.isEmpty
            ? 1
            : data.map((d) => d.value).reduce((a, b) => a > b ? a : b) * 1.1);

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          maxY: maxValue,
          backgroundColor: Colors.transparent,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: colors.border,
              strokeWidth: 0.5,
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(color: colors.border, width: 1),
              left: BorderSide(color: colors.border, width: 1),
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: showLabels,
                reservedSize: 28,
                  getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= data.length) {
                    return const SizedBox.shrink();
                  }
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      data[idx].label,
                      style: styles.monoSm.copyWith(color: colors.textMuted),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (int i = 0; i < data.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: data[i].value,
                    color: color,
                    width: data.length > 20 ? 6 : 12,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(3),
                    ),
                  ),
                ],
              ),
          ],
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => colors.surface,
              getTooltipItem: (group, gi, rod, ri) => BarTooltipItem(
                data[group.x].value.toStringAsFixed(0),
                styles.bodySm.copyWith(color: colors.textPrimary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
