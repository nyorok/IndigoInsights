import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/views/insights/stability_pool_account/stability_pool_account_distribution_pie_chart.dart';
import 'package:indigo_insights/views/insights/stability_pool_account/stability_pool_account_unclaimed_rewards_pie_chart.dart';

class StabilityPoolAccountInsights extends HookConsumerWidget {
  const StabilityPoolAccountInsights({super.key});

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
                chartCard(
                  const StabilityPoolAccountDistributionPieChart(asset: 'iUSD'),
                  context,
                ),
                chartCard(
                  const StabilityPoolAccountDistributionPieChart(asset: "iBTC"),
                  context,
                ),
                chartCard(
                  const StabilityPoolAccountDistributionPieChart(asset: "iETH"),
                  context,
                ),
                chartCard(
                  const StabilityPoolAccountUnclaimedRewardsPieChart(
                    asset: 'iUSD',
                  ),
                  context,
                ),
                chartCard(
                  const StabilityPoolAccountUnclaimedRewardsPieChart(
                    asset: "iBTC",
                  ),
                  context,
                ),
                chartCard(
                  const StabilityPoolAccountUnclaimedRewardsPieChart(
                    asset: "iETH",
                  ),
                  context,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  informationCard(Widget widget, BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.all(8),
        child: Padding(padding: const EdgeInsets.all(16), child: widget),
      ),
    ).animate().scaleY(duration: 300.ms, curve: Curves.easeInOut);
  }

  chartCard(Widget widget, BuildContext context) {
    return cardContainer(
      Card(
        elevation: 2,
        margin: const EdgeInsets.all(8),
        child: Padding(padding: const EdgeInsets.all(4), child: widget),
      ).animate().scaleY(duration: 300.ms, curve: Curves.easeInOut),
      context,
    );
  }

  cardContainer(Widget widget, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double width = screenWidth / 2 > 480 ? screenWidth / 2 : 480;

    final screenHeight = MediaQuery.of(context).size.height;
    final double height = screenHeight > screenWidth
        ? width + 40
        : screenHeight - 68;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: width, maxHeight: height),
      child: widget,
    );
  }
}
