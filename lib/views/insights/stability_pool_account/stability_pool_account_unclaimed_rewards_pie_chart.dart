import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/providers/stability_pool_account_provider.dart';
import 'package:indigo_insights/providers/stability_pool_provider.dart';
import 'package:indigo_insights/theme/color_scheme.dart';
import 'package:indigo_insights/utils/formatters.dart';
import 'package:indigo_insights/utils/loader.dart';
import 'package:indigo_insights/utils/page_title.dart';
import 'package:indigo_insights/widgets/distribution_pie_chart.dart';

final stabilityPoolAccountUnclaimedRewardsProvider =
    FutureProvider.family<List<double>, String>((ref, asset) async {
  final stabilityPool = await ref
      .watch(stabilityPoolProvider.future)
      .then((value) => value.firstWhere((e) => e.asset == asset));

  return await ref.watch(stabilityPoolAccountProvider.future).then((value) =>
      value
          .where((e) => e.asset == asset)
          .map((e) => stabilityPool.getAccountUnclaimedRewards(e))
          .toList());
});

class StabilityPoolAccountUnclaimedRewardsPieChart extends HookConsumerWidget {
  const StabilityPoolAccountUnclaimedRewardsPieChart(
      {super.key, required this.asset});
  final String asset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    getAccountUnclaimedRewardsData(List<double> accountsUnclaimedRewards) {
      accountsUnclaimedRewards.sort();
      double totalSum = accountsUnclaimedRewards
          .map((value) => value)
          .reduce((a, b) => a + b);

      final bigAmount = accountsUnclaimedRewards
          .map((e) => (percent: e / totalSum, amount: e))
          .where((e) => e.percent >= 0.01)
          .toList()
          .map((e) => (
                title: '${numberFormatter((e.percent * 100), 2)}%',
                value: e.percent,
                touchedInfo: '${numberFormatter(e.amount, 2)} ADA'
              ))
          .toList();
      final smallerAmounts =
          accountsUnclaimedRewards.where((e) => e / totalSum < 0.01);

      bigAmount.insert(0, (
        title:
            '>1% (${numberFormatter((smallerAmounts.sum / totalSum * 100), 2)}%)',
        value: smallerAmounts.sum / totalSum,
        touchedInfo: '${numberFormatter((smallerAmounts.sum), 2)} ADA'
      ));

      return bigAmount;
    }

    return ref.watch(stabilityPoolAccountUnclaimedRewardsProvider(asset)).when(
        data: (accountsUnclaimedRewards) {
          final accountsUnclaimedRewardsData =
              getAccountUnclaimedRewardsData(accountsUnclaimedRewards);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PageTitle(
                          title:
                              "Stability Pool Accounts Unclaimed Rewards ($asset)"),
                      Text(
                          "Total: ${numberFormatter(accountsUnclaimedRewards.sum, 2)} ADA"),
                      Text(
                          "Potential Governance Rewards: ${numberFormatter(accountsUnclaimedRewards.sum * 0.02, 2)} ADA")
                    ],
                  ),
                ),
              ),
              Expanded(
                child: DistributionPieChartWidget(
                  pieValues: accountsUnclaimedRewardsData,
                  colorRange: generateColorRange(Colors.green, secondaryRed,
                      accountsUnclaimedRewardsData.length),
                ),
              ),
            ],
          );
        },
        error: (error, stackTrade) => Text(error.toString()),
        loading: () => const Loader());
  }
}
