import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:indigo_insights/theme/app_color_scheme.dart';
import 'package:indigo_insights/theme/app_text_styles.dart';
import 'package:indigo_insights/utils/formatters.dart';

class PercentageAmountData {
  final double percentage;
  final double amount;

  const PercentageAmountData(this.percentage, this.amount);
}

class PercentageAmountChart extends StatelessWidget {
  const PercentageAmountChart({
    super.key,
    required this.title,
    required this.data,
    required this.colors,
    required this.gradients,
    required this.labels,
    required this.currency,
    required this.mintedSupply,
  });

  final String title;
  final String currency;
  final double mintedSupply;
  final List<List<PercentageAmountData>> data;
  final List<Color> colors;
  final List<Gradient?> gradients;
  final List<String> labels;
  static const double _rightLabelWidth = 44;

  double getAmountEnd() => data
      .expand((list) => list)
      .map((e) => e.amount)
      .reduce((value, element) => value > element ? value : element);

  List<BarChartGroupData> getChartBars(double widgetWidth) {
    final bars = data
        .mapIndexed(
          (index, groupData) =>
              groupData.map((data) => (index: index, data: data)),
        )
        .expand((e) => e)
        .groupListsBy<String>((g) => (g.data.percentage).toString())
        .entries
        .map((entry) {
          final rodStackItems = List<BarChartRodStackItem>.from([]);
          double lastAmount = 0;

          for (var e in entry.value) {
            rodStackItems.add(
              BarChartRodStackItem(
                lastAmount,
                e.data.amount + lastAmount,
                colors[e.index],
              ),
            );
            lastAmount += e.data.amount;
          }

          return (
            key: entry.key,
            bar: BarChartRodData(
              width:
                  (widgetWidth - _rightLabelWidth) // chart width
                      /
                      100 // total number of bars
                      -
                  1.2, // space between bars
              borderRadius: BorderRadius.zero,
              toY: rodStackItems.last.toY,
              rodStackItems: rodStackItems,
            ),
          );
        })
        .toList();
    log('${bars.length}');
    return bars
        .map(
          (b) => BarChartGroupData(
            x: double.parse(b.key).toInt(),
            barsSpace: 10,
            barRods: [b.bar],
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (colors.length < data.length) {
      throw Exception('Not enough colors for each data line');
    }
    if (gradients.length < data.length) {
      throw Exception('Not enough gradients for each data line');
    }
    if (labels.length < data.length) {
      throw Exception('Not enough labels for each data line');
    }

    final appColors = AppColorScheme.of(context);
    final styles = AppTextStyles.of(context);

    return Column(
      children: [
        Container(
          alignment: Alignment.bottomLeft,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            children: [
              Text(title, style: styles.cardTitle),
              Expanded(
                child: Wrap(
                  alignment: WrapAlignment.end,
                  children: labels
                      .mapIndexed(
                        (index, label) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Text(
                            label,
                            style: styles.bodyMd.copyWith(
                              color: colors[index],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: LayoutBuilder(
            builder: (context, constraints) => BarChart(
              BarChartData(
                borderData: FlBorderData(show: true),
                gridData: const FlGridData(show: true),
                barGroups: getChartBars(constraints.maxWidth),
                maxY: getAmountEnd() * 1.2,
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(
                      reservedSize: _rightLabelWidth,
                      showTitles: false,
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(reservedSize: 30, showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, titleMeta) {
                        if ((value) % 50 != 0) {
                          return const SizedBox();
                        }
                        return SideTitleWidget(
                          fitInside: SideTitleFitInsideData.fromTitleMeta(
                            titleMeta,
                            distanceFromEdge: 0,
                          ),
                          meta: titleMeta,
                          child: Text(
                            '${value.toInt()}%',
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: 0.2 * mintedSupply,
                      color: appColors.success,
                      label: HorizontalLineLabel(
                        show: true,
                        labelResolver: (line) => '20% minted supply',
                        alignment: Alignment.topLeft,
                        style: styles.bodySm.copyWith(color: appColors.textPrimary),
                      ),
                    ),
                    HorizontalLine(
                      y: 0.35 * mintedSupply,
                      color: appColors.warning,
                      label: HorizontalLineLabel(
                        show: true,
                        labelResolver: (line) => '35% minted supply',
                        alignment: Alignment.topLeft,
                        style: styles.bodySm.copyWith(color: appColors.textPrimary),
                      ),
                    ),
                    HorizontalLine(
                      y: 0.5 * mintedSupply,
                      color: appColors.error,
                      label: HorizontalLineLabel(
                        show: true,
                        labelResolver: (line) => '50% minted supply',
                        alignment: Alignment.topLeft,
                        style: styles.bodySm.copyWith(color: appColors.textPrimary),
                      ),
                    ),
                  ],
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    getTooltipColor: (x) => appColors.surface,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${group.x}%: ${numberFormatter(rod.toY, 0)} $currency',
                        styles.bodySm.copyWith(
                          color: colors[rodIndex],
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          ),
        ),
      ],
    ).animate().fade(duration: 500.ms, curve: Curves.easeInOut);
  }
}
