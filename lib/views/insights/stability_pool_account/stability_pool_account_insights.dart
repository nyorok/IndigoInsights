import 'package:flutter/material.dart';
import 'package:indigo_insights/views/insights/stability_pool_account/stability_pool_account_distribution_pie_chart.dart';
import 'package:indigo_insights/views/insights/stability_pool_account/stability_pool_account_unclaimed_rewards_pie_chart.dart';
import 'package:indigo_insights/widgets/ii_asset_tabs.dart';
import 'package:indigo_insights/widgets/ii_card.dart';
import 'package:indigo_insights/widgets/ii_top_bar.dart';

class StabilityPoolAccountInsights extends StatelessWidget {
  const StabilityPoolAccountInsights({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const IITopBar(title: 'SP Account'),
        Expanded(
          child: SelectionArea(
            child: IIAssetTabs(
              tabContentBuilder: (asset) {
                final isDesktop =
                    MediaQuery.of(context).size.width >= 700;
                final distChart = IICard(
                  padding: EdgeInsets.zero,
                  child: StabilityPoolAccountDistributionPieChart(
                    asset: asset.asset,
                  ),
                );
                final rewardsChart = IICard(
                  padding: EdgeInsets.zero,
                  child: StabilityPoolAccountUnclaimedRewardsPieChart(
                    asset: asset.asset,
                  ),
                );
                if (isDesktop) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(child: distChart),
                        const SizedBox(width: 16),
                        Expanded(child: rewardsChart),
                      ],
                    ),
                  );
                }
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 320, child: distChart),
                      const SizedBox(height: 16),
                      SizedBox(height: 320, child: rewardsChart),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
