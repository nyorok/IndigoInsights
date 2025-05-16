import 'dart:math';

import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:indigo_insights/utils/formatters.dart';

class AmountPercentageData {
  final double percent;
  final double amount;

  const AmountPercentageData(this.percent, this.amount);
}

List<AmountPercentageData> normalizeAmountPercentageData(
    List<AmountPercentageData> inputList,
    int maxPercentage,
    double initialAmount) {
  List<AmountPercentageData> normalizedList = [];

  int currentPercent = 0;
  double lastAmount = initialAmount;
  int inputIndex = 0;

  while (currentPercent <= maxPercentage) {
    if (inputIndex < inputList.length) {
      final percent = (inputList[inputIndex].percent * 100).round();
      if (percent == currentPercent) {
        normalizedList.add(AmountPercentageData(
            currentPercent / 100.0, inputList[inputIndex].amount));
        inputIndex++;
      } else {
        if (currentPercent > percent) {
          throw Exception(
              "normalizeAmountPercentageData: Input should have unique percents by interval 1");
        }
        normalizedList
            .add(AmountPercentageData(currentPercent / 100.0, lastAmount));
      }
      lastAmount = inputList[inputIndex].amount;
    }

    currentPercent += 1;
  }

  return normalizedList;
}

class AmountPercentageChart extends StatelessWidget {
  const AmountPercentageChart(
      {super.key,
      required this.data,
      required this.colors,
      required this.gradients,
      required this.labels,
      required this.currency});

  final String currency;
  final List<List<AmountPercentageData>> data;
  final List<Color> colors;
  final List<Gradient?> gradients;
  final List<String> labels;

  double getPercentStart() => data
      .expand((list) => list)
      .map((e) => e.percent)
      .reduce((value, element) => value < element ? value : element);

  double getPercentEnd() => data
      .expand((list) => list)
      .map((e) => e.percent)
      .reduce((value, element) => value > element ? value : element);

  double getAmountStart() => data
      .expand((list) => list)
      .map((e) => e.amount)
      .reduce((value, element) => value < element ? value : element);

  double getAmountEnd() => data
      .expand((list) => list)
      .map((e) => e.amount)
      .reduce((value, element) => value > element ? value : element);

  double roundToNearestPowerOf10(double value) {
    if (value == 0) return 0;

    int power = (log(value) / log(10)).floor();
    double base = pow(10, power).toDouble();
    int firstDigit = (value / base).ceil();

    return firstDigit * base;
  }

  double getPercentInterval() => 0.10;

  double getAmountInterval() =>
      roundToNearestPowerOf10((getAmountEnd() - getAmountStart()) / 20);

  List<LineChartBarData> getChartLines() => data
      .mapIndexed((index, lineData) => LineChartBarData(
            color: colors[index],
            belowBarData: BarAreaData(show: true, gradient: gradients[index]),
            spots: lineData
                .map((dotData) => FlSpot(dotData.percent, dotData.amount))
                .toList(),
            isCurved: true,
            curveSmoothness: 0.01,
            dotData: const FlDotData(show: false),
          ))
      .toList();

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

    final amountStart = getAmountStart();
    final amountEnd = getAmountEnd();
    final higherAmount = amountStart.abs() > amountEnd.abs()
        ? amountStart.abs()
        : amountEnd.abs();
    final abbreviation = getAbbreviation(higherAmount);

    double getLabelSize() {
      final painter = TextPainter(
        text: TextSpan(
            text:
                "-${numberAbbreviatedFormatter(getAmountEnd(), abbreviation)}"),
        textDirection: TextDirection.ltr,
      );
      painter.layout();
      return painter.width + 12;
    }

    return Column(
      children: [
        Container(
          alignment: Alignment.bottomLeft,
          padding: const EdgeInsets.only(top: 8, left: 30),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: getLabelSize()),
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    children: labels
                        .mapIndexed((index, e) => Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                e,
                                style: TextStyle(
                                    color: colors[index],
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12.8,
                                    fontFamily: "Quicksand"),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              )
            ],
          ),
        ),
        Expanded(
          child: LineChart(
            LineChartData(
              minX: getPercentStart(),
              maxX: getPercentEnd(),
              minY: -higherAmount,
              maxY: higherAmount,
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: 0,
                    color: Colors.amber.shade900,
                    strokeWidth: 2,
                    dashArray: [5, 2],
                  ),
                ],
              ),
              titlesData: FlTitlesData(
                topTitles: AxisTitles(
                    sideTitles: SideTitles(
                        reservedSize: 15,
                        showTitles: true,
                        getTitlesWidget: (value, titleMeta) => const Text(""))),
                leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                        reservedSize: 30,
                        showTitles: true,
                        getTitlesWidget: (value, titleMeta) => const Text(""))),
                bottomTitles: AxisTitles(
                  axisNameWidget: const Text(
                    "ADA Price Fluctuation",
                    style: TextStyle(fontSize: 12),
                  ),
                  axisNameSize: 16,
                  sideTitles: SideTitles(
                    interval: getPercentInterval(),
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, titleMeta) {
                      return SideTitleWidget(
                        fitInside:
                            SideTitleFitInsideData.fromTitleMeta(titleMeta),
                        meta: titleMeta,
                        child: Text('${(-value * 100).round()}%'),
                      );
                    },
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    reservedSize: getLabelSize(),
                    showTitles: true,
                    getTitlesWidget: (value, titleMeta) => Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Row(children: [
                        Text(numberAbbreviatedFormatter(value, abbreviation))
                      ]),
                    ),
                  ),
                ),
              ),
              borderData: FlBorderData(show: true),
              gridData: const FlGridData(show: true),
              lineBarsData: getChartLines(),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (x) => Theme.of(context).colorScheme.surface,
                  getTooltipItems: (List<LineBarSpot> touchedSpots) {
                    return touchedSpots.map((LineBarSpot touchedSpot) {
                      final spotData =
                          touchedSpot.bar.spots[touchedSpot.spotIndex];
                      final double amount = spotData.y;
                      return LineTooltipItem(
                        "${labels[touchedSpot.barIndex]}: ${numberFormatter(amount, 0)} $currency",
                        TextStyle(
                            color: colors[touchedSpot.barIndex],
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                            fontFamily: "Quicksand"),
                      );
                    }).toList();
                  },
                ),
                handleBuiltInTouches: true,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
