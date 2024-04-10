import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:flutter_hooks/flutter_hooks.dart';

List<Color> generateColorRange(Color startColor, Color endColor, int steps) {
  final double stepSize = 1.0 / (steps - 1);

  List<Color> colorRange = [];

  for (int i = 0; i < steps; i++) {
    final double factor = i * stepSize;
    int red =
        (startColor.red + (factor * (endColor.red - startColor.red))).round();
    int green =
        (startColor.green + (factor * (endColor.green - startColor.green)))
            .round();
    int blue = (startColor.blue + (factor * (endColor.blue - startColor.blue)))
        .round();

    colorRange.add(Color.fromARGB(255, red, green, blue));
  }

  return colorRange;
}

class DistributionPieChartWidget extends HookWidget {
  const DistributionPieChartWidget(
      {super.key, required this.pieValues, required this.colorRange});

  final List<({String title, double value, String touchedInfo})> pieValues;
  final List<Color> colorRange;

  @override
  Widget build(BuildContext context) {
    if (colorRange.length < pieValues.length) {
      throw Exception("Not enough colors for each pie part");
    }
    final touchedIndex = useState(-1);

    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: LayoutBuilder(builder: (context, constraints) {
          final shortestSide = constraints.biggest.shortestSide;
          return PieChart(
            PieChartData(
                sections: pieValues.mapIndexed((index, tuple) {
                  final isTouched = index == touchedIndex.value;
                  final logValue =
                      -1 / log(tuple.value / pieValues.map((x) => x.value).sum);

                  return PieChartSectionData(
                    color: colorRange[index],
                    value: logValue,
                    title: isTouched ? tuple.touchedInfo : tuple.title,
                    radius: shortestSide / (isTouched ? 8 : 10),
                    titleStyle: TextStyle(
                      fontSize: isTouched ? 18.0 : 12.0,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      fontFamily: "Quicksand",
                      shadows: const [
                        Shadow(color: Colors.black, blurRadius: 2)
                      ],
                    ),
                  );
                }).toList(),
                pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  if (!event.isInterestedForInteractions ||
                      pieTouchResponse == null ||
                      pieTouchResponse.touchedSection == null) {
                    touchedIndex.value = -1;
                  } else {
                    touchedIndex.value =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                  }
                }),
                sectionsSpace: 2,
                centerSpaceRadius: shortestSide / 2.8),
            swapAnimationDuration: const Duration(milliseconds: 200),
            swapAnimationCurve: Curves.linear,
          );
        }),
      ),
    );
  }
}
