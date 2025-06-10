import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:indigo_insights/utils/formatters.dart';

import '../utils/page_title.dart';

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

  double getAmountEnd() => data
      .expand((list) => list)
      .map((e) => e.amount)
      .reduce((value, element) => value > element ? value : element);

  getChartBars() {
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
              width: 5,
              borderRadius: BorderRadius.zero,
              toY: rodStackItems.last.toY,
              rodStackItems: rodStackItems,
            ),
          );
        })
        .toList();

    return bars
        .map(
          (b) => BarChartGroupData(
            x: double.parse(b.key).toInt(),
            barsSpace: 50,
            barRods: [b.bar],
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (colors.length < data.length) {
      throw Exception("Not enough colors for each data line");
    }
    if (gradients.length < data.length) {
      throw Exception("Not enough gradients for each data line");
    }
    if (labels.length < data.length) {
      throw Exception("Not enough labels for each data line");
    }

    return Column(
      children: [
        Container(
          alignment: Alignment.bottomLeft,
          padding: const EdgeInsets.only(top: 8, left: 30),
          child: Row(
            children: [
              PageTitle(title: title),
              Expanded(
                child: Wrap(
                  alignment: WrapAlignment.end,
                  children: labels
                      .mapIndexed(
                        (index, label) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Text(
                            label,
                            style: TextStyle(
                              color: colors[index],
                              fontWeight: FontWeight.w600,
                              fontSize: 12.8,
                              fontFamily: "Quicksand",
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
          child: BarChart(
            BarChartData(
              borderData: FlBorderData(show: true),
              gridData: const FlGridData(show: true),
              barGroups: getChartBars(),
              maxY: getAmountEnd() * 1.2,
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(reservedSize: 44, showTitles: false),
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
                        ),
                        meta: titleMeta,
                        child: Text(
                          '${value.toInt()}%',
                          style: const TextStyle(fontSize: 12.8),
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
                    color: Colors.green,
                    label: HorizontalLineLabel(
                      show: true,
                      labelResolver: (line) => '20% minted supply',
                      alignment: Alignment.topLeft,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: "Quicksand",
                      ),
                    ),
                  ),
                  HorizontalLine(
                    y: 0.35 * mintedSupply,
                    color: Colors.yellow,
                    label: HorizontalLineLabel(
                      show: true,
                      labelResolver: (line) => '35% minted supply',
                      alignment: Alignment.topLeft,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: "Quicksand",
                      ),
                    ),
                  ),
                  HorizontalLine(
                    y: 0.5 * mintedSupply,
                    color: Colors.red,
                    label: HorizontalLineLabel(
                      show: true,
                      labelResolver: (line) => '50% minted supply',
                      alignment: Alignment.topLeft,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: "Quicksand",
                      ),
                    ),
                  ),
                ],
              ),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  getTooltipColor: (x) => Theme.of(context).colorScheme.surface,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      "${group.x}%: ${numberFormatter(rod.toY, 0)} $currency",
                      TextStyle(
                        color: colors[rodIndex],
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                        fontFamily: "Quicksand",
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    ).animate().fade(duration: 500.ms, curve: Curves.easeInOut);
  }
}
