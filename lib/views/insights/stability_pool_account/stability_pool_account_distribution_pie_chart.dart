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

final stabilityPoolAccountBalanceProvider =
    FutureProvider.family<List<double>, String>((ref, asset) async {
  final stabilityPool = await ref
      .watch(stabilityPoolProvider.future)
      .then((value) => value.firstWhere((e) => e.asset == asset));

  return await ref.watch(stabilityPoolAccountProvider.future).then((value) =>
      value
          .where((e) => e.asset == asset)
          .map((e) => stabilityPool.getAccountBalance(e))
          .toList());
});

class StabilityPoolAccountDistributionPieChart extends HookConsumerWidget {
  const StabilityPoolAccountDistributionPieChart(
      {super.key, required this.asset});
  final String asset;

  List<({String title, String touchedInfo, double value})>
      getAccountDistribution(List<double> accountsbalances) {
    accountsbalances.sort();

    double totalSum =
        accountsbalances.map((value) => value).reduce((a, b) => a + b);

    final bigAmount = accountsbalances
        .map((e) => (percent: e / totalSum, amount: e))
        .where((e) => e.percent >= 0.01)
        .toList()
        .map((e) => (
              title: '${numberFormatter((e.percent * 100), 2)}%',
              value: e.percent,
              touchedInfo: '${numberFormatter(e.amount, 2)} $asset'
            ))
        .toList();
    final smallerAmounts = accountsbalances.where((e) => e / totalSum < 0.01);

    bigAmount.insert(0, (
      title:
          '>1% (${numberFormatter((smallerAmounts.sum / totalSum * 100), 2)}%)',
      value: smallerAmounts.sum / totalSum,
      touchedInfo: '${numberFormatter((smallerAmounts.sum), 2)} $asset'
    ));

    return bigAmount;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(stabilityPoolAccountBalanceProvider(asset)).when(
        data: (accountsBalances) {
          final accountDistribution = getAccountDistribution(accountsBalances);

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
                              "Stability Pool Accounts Distribution ($asset)"),
                      Text(
                          "Total: ${numberFormatter(accountsBalances.sum, 2)} $asset")
                    ],
                  ),
                ),
              ),
              Expanded(
                child: DistributionPieChartWidget(
                  pieValues: accountDistribution,
                  colorRange: generateColorRange(
                      Colors.green, secondaryRed, accountDistribution.length),
                ),
              ),
            ],
          );
        },
        error: (error, stackTrade) => Text(error.toString()),
        loading: () => const Loader());
  }
}
