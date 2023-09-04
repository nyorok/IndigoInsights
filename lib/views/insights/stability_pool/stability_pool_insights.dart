import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/views/insights/stability_pool/stability_pool_information.dart';
import 'package:indigo_insights/views/insights/stability_pool/stability_pool_solvency_chart.dart';

class StabilityPoolInsights extends HookConsumerWidget {
  const StabilityPoolInsights({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: SelectionArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Align(
            alignment: Alignment.topLeft,
            child: Wrap(
              alignment: WrapAlignment.end,
              children: [
                Column(
                  children: [
                    informationCard(
                        const StabilityPoolInformation(
                          asset: "iUSD",
                        ),
                        context),
                    chartCard(const StabilityPoolSolvencyChart(asset: "iUSD"),
                        context),
                  ],
                ),
                Column(
                  children: [
                    informationCard(
                        const StabilityPoolInformation(
                          asset: "iBTC",
                        ),
                        context),
                    chartCard(const StabilityPoolSolvencyChart(asset: "iBTC"),
                        context),
                  ],
                ),
                Column(
                  children: [
                    informationCard(
                        const StabilityPoolInformation(
                          asset: "iETH",
                        ),
                        context),
                    chartCard(const StabilityPoolSolvencyChart(asset: "iETH"),
                        context),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  informationCard(Widget widget, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double width = screenWidth - 640 > 640 ? 640 : screenWidth;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: width),
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.all(8),
        child: Padding(padding: const EdgeInsets.all(16), child: widget),
      ),
    );
  }

  chartCard(Widget widget, BuildContext context) {
    return cardContainer(
        Card(
          elevation: 2,
          margin: const EdgeInsets.all(8),
          child: Padding(padding: const EdgeInsets.all(4), child: widget),
        ),
        context);
  }

  cardContainer(Widget widget, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double width = screenWidth - 640 > 640 ? 640 : screenWidth;

    final screenHeight = MediaQuery.of(context).size.height;
    final double height = screenHeight > screenWidth
        ? screenHeight - 200
        : screenHeight - 440 > 440
            ? 440
            : screenHeight;

    return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: width, maxHeight: height),
        child: widget);
  }
}
