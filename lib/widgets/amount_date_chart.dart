import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:indigo_insights/utils/formatters.dart';
import 'package:intl/intl.dart' as intl;

import '../utils/page_title.dart';

class AmountDateData {
  final DateTime date;
  final double amount;

  const AmountDateData(this.date, this.amount);
}

DateTime getDate(DateTime date) => DateTime(date.year, date.month, date.day);

List<AmountDateData> normalizeAmountDateData(
  List<AmountDateData> inputList,
  DateTime startDate,
  DateTime endDate,
) {
  List<AmountDateData> normalizedList = [];

  DateTime currentDate = getDate(startDate);
  double lastAmount = inputList.first.amount;
  int inputIndex = 0;
  DateTime lastDate = getDate(endDate).add(const Duration(days: 1));

  while (currentDate.isBefore(lastDate)) {
    if (inputIndex < inputList.length) {
      final inputDate = inputList[inputIndex].date;
      if (currentDate.isAtSameMomentAs(getDate(inputDate))) {
        normalizedList.add(
          AmountDateData(currentDate, inputList[inputIndex].amount),
        );
        inputIndex++;
      } else {
        if (currentDate.isAfter(getDate(inputDate))) {
          print(
            "normalizeAmountDateData: ${dateFormatter(currentDate)} is after ${getDate(inputDate)}",
          );
        } else {
          normalizedList.add(AmountDateData(currentDate, lastAmount));
        }
      }
      lastAmount = inputIndex < inputList.length
          ? inputList[inputIndex].amount
          : lastAmount;
    } else {
      normalizedList.add(AmountDateData(currentDate, lastAmount));
    }

    currentDate = currentDate.add(const Duration(days: 1));
  }

  return normalizedList;
}

class AmountDateChart extends StatelessWidget {
  const AmountDateChart({
    super.key,
    required this.title,
    required this.data,
    required this.colors,
    required this.gradients,
    required this.labels,
    required this.currency,
    this.minY,
    this.maxY,
  });

  final String title;
  final String currency;
  final List<List<AmountDateData>> data;
  final List<Color> colors;
  final List<Gradient?> gradients;
  final List<String> labels;
  final double? minY;
  final double? maxY;

  DateTime getDateStart() => data
      .expand((list) => list)
      .map((e) => e.date)
      .reduce(
        (value, element) =>
            value.microsecondsSinceEpoch < element.microsecondsSinceEpoch
            ? getDate(value.toUtc())
            : getDate(element.toUtc()),
      );

  DateTime getDateEnd() => data
      .expand((list) => list)
      .map((e) => e.date)
      .reduce(
        (value, element) =>
            value.microsecondsSinceEpoch > element.microsecondsSinceEpoch
            ? getDate(value.toUtc())
            : getDate(element.toUtc()),
      );

  double getAmountStart() =>
      minY ??
      data
          .expand((list) => list)
          .map((e) => e.amount)
          .reduce((value, element) => value < element ? value : element);

  double getAmountEnd() =>
      maxY ??
      data
              .expand((list) => list)
              .map((e) => e.amount)
              .reduce((value, element) => value > element ? value : element) *
          1.2;

  double getAmountInterval() => (getAmountEnd() - getAmountStart()) / 20;

  int getDateInterval() =>
      (getDateStart().difference(getDateEnd()).inDays / 6).abs().ceil();

  List<LineChartBarData> getChartLines() => data
      .mapIndexed(
        (index, lineData) => LineChartBarData(
          color: colors[index],
          belowBarData: BarAreaData(show: true, gradient: gradients[index]),
          spots: lineData
              .map(
                (dotData) => FlSpot(
                  getDate(
                    dotData.date.toUtc(),
                  ).millisecondsSinceEpoch.toDouble(),
                  dotData.amount,
                ),
              )
              .toList(),
          isCurved: true,
          curveSmoothness: 0.01,
          dotData: FlDotData(show: false),
        ),
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    DateTime? previousDateLabel;
    double? previousAmount;
    double? interval;

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
          text: numberAbbreviatedFormatter(getAmountEnd(), abbreviation),
        ),
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
              PageTitle(
                title: title,
              ).animate().fade(duration: 300.ms, curve: Curves.easeInOut),
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
              ).animate().fade(duration: 300.ms, curve: Curves.easeInOut),
            ],
          ),
        ),
        Expanded(
          child: LineChart(
            LineChartData(
              minX: getDateStart().millisecondsSinceEpoch.toDouble(),
              maxX: getDateEnd().millisecondsSinceEpoch.toDouble(),
              minY: getAmountStart(),
              maxY: getAmountEnd(),
              titlesData: FlTitlesData(
                topTitles: AxisTitles(
                  sideTitles: SideTitles(
                    reservedSize: 15,
                    showTitles: true,
                    getTitlesWidget: (value, titleMeta) => const Text(""),
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    reservedSize: 30,
                    showTitles: true,
                    getTitlesWidget: (value, titleMeta) => const Text(""),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    interval: Duration(
                      days: getDateInterval(),
                    ).inMilliseconds.toDouble(),
                    showTitles: true,
                    reservedSize: 36,
                    getTitlesWidget: (value, titleMeta) {
                      final dateTime = getDate(
                        DateTime.fromMillisecondsSinceEpoch(
                          value.toInt(),
                        ).toUtc(),
                      );
                      if (previousDateLabel != null &&
                          dateTime.difference(previousDateLabel!).inDays.abs() <
                              getDateInterval()) {
                        previousDateLabel = dateTime;
                        return const SizedBox();
                      }
                      previousDateLabel = dateTime;

                      return SideTitleWidget(
                        meta: titleMeta,
                        child: Text(
                          getDateInterval() >= 30
                              ? '${dateTime.month}/${dateTime.year.toString().substring(2)}'
                              : intl.DateFormat('yyyy-MM-dd').format(dateTime),
                          style: const TextStyle(fontSize: 9),
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    reservedSize: getLabelSize(),
                    showTitles: true,
                    getTitlesWidget: (value, titleMeta) {
                      if (previousAmount == null) {
                        previousAmount = value;
                      } else {
                        if (interval == null) {
                          interval = value - previousAmount!;
                        } else {
                          if (value.remainder(interval!) > 0) {
                            return const SizedBox();
                          }
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Row(
                          children: [
                            Text(
                              '${numberAbbreviated(value, abbreviation).toStringAsFixed(2)}${abbreviation?.name ?? ''}',
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: true),
              gridData: const FlGridData(show: true),
              lineBarsData: getChartLines(),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  maxContentWidth: 240,
                  getTooltipColor: (x) => Theme.of(context).colorScheme.surface,
                  getTooltipItems: (List<LineBarSpot> touchedSpots) {
                    return touchedSpots.map((LineBarSpot touchedSpot) {
                      final spotData =
                          touchedSpot.bar.spots[touchedSpot.spotIndex];
                      final double amount = spotData.y;

                      final DateTime date = DateTime.fromMillisecondsSinceEpoch(
                        touchedSpots
                            .first
                            .bar
                            .spots[touchedSpots.first.spotIndex]
                            .x
                            .toInt(),
                      );
                      final String formattedDate = intl.DateFormat(
                        'yyyy/MM/dd',
                      ).format(date);

                      return LineTooltipItem(
                        "${touchedSpot.barIndex == 0 ? '$formattedDate ${labels[touchedSpot.barIndex]}' : labels[touchedSpot.barIndex]}: ${numberFormatter(amount, 0)} $currency",
                        TextStyle(
                          color: colors[touchedSpot.barIndex],
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                          fontFamily: "Quicksand",
                        ),
                      );
                    }).toList();
                  },
                ),
                handleBuiltInTouches: true,
              ),
            ),
          ),
        ).animate().fade(duration: 500.ms, curve: Curves.easeInOut),
      ],
    );
  }
}
