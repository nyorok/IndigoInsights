import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:indigo_insights/models/stability_pool.dart';
import 'package:indigo_insights/models/stability_pool_account.dart';
import 'package:indigo_insights/repositories/stability_pool_account_repository.dart';
import 'package:indigo_insights/repositories/stability_pool_repository.dart';
import 'package:indigo_insights/service_locator.dart';
import 'package:indigo_insights/theme/color_scheme.dart';
import 'package:indigo_insights/utils/async_builder.dart';
import 'package:indigo_insights/utils/formatters.dart';
import 'package:indigo_insights/utils/page_title.dart';
import 'package:indigo_insights/widgets/distribution_pie_chart.dart';

class StabilityPoolAccountUnclaimedRewardsPieChart extends StatelessWidget {
  const StabilityPoolAccountUnclaimedRewardsPieChart({
    super.key,
    required this.asset,
  });

  final String asset;

  List<({String title, String touchedInfo, double value})> _getAccountUnclaimedRewardsData(
    List<double> accountsUnclaimedRewards,
  ) {
    accountsUnclaimedRewards.sort();
    final double totalSum = accountsUnclaimedRewards.reduce((a, b) => a + b);

    final bigAmount = accountsUnclaimedRewards
        .map((e) => (percent: e / totalSum, amount: e))
        .where((e) => e.percent >= 0.01)
        .map(
          (e) => (
            title: '${numberFormatter((e.percent * 100), 2)}%',
            value: e.percent,
            touchedInfo: '${numberFormatter(e.amount, 2)} ADA',
          ),
        )
        .toList();
    final smallerAmounts = accountsUnclaimedRewards.where((e) => e / totalSum < 0.01);

    bigAmount.insert(0, (
      title:
          '>1% (${numberFormatter((smallerAmounts.sum / totalSum * 100), 2)}%)',
      value: smallerAmounts.sum / totalSum,
      touchedInfo: '${numberFormatter((smallerAmounts.sum), 2)} ADA',
    ));

    return bigAmount;
  }

  @override
  Widget build(BuildContext context) {
    return AsyncBuilder(
      fetcher: () => Future.wait([
        sl<StabilityPoolRepository>().getPools(),
        sl<StabilityPoolAccountRepository>().getAccounts(),
      ]).then((results) {
        final pool = (results[0] as List<StabilityPool>)
            .firstWhere((e) => e.asset == asset);
        return (results[1] as List<StabilityPoolAccount>)
            .where((e) => e.asset == asset)
            .map((e) => pool.getAccountUnclaimedRewards(e))
            .toList();
      }),
      builder: (accountsUnclaimedRewards) {
        final accountsUnclaimedRewardsData =
            _getAccountUnclaimedRewardsData(accountsUnclaimedRewards);

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
                          'Stability Pool Accounts Unclaimed Rewards ($asset)',
                    ),
                    Text(
                      'Total: ${numberFormatter(accountsUnclaimedRewards.sum, 2)} ADA',
                    ),
                    Text(
                      'Potential Governance Rewards: ${numberFormatter(accountsUnclaimedRewards.sum * 0.02, 2)} ADA',
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: DistributionPieChartWidget(
                pieValues: accountsUnclaimedRewardsData,
                colorRange: generateColorRange(
                  Colors.green,
                  secondaryRed,
                  accountsUnclaimedRewardsData.length,
                ),
              ),
            ),
          ],
        );
      },
      errorBuilder: (error, retry) => Text(error.toString()),
    );
  }
}
