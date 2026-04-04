import 'package:flutter/material.dart';
import 'package:indigo_insights/views/insights/redemption/redeemable_over_rmrs_chart.dart';
import 'package:indigo_insights/views/insights/redemption/redemption_fee_breakdown_chart.dart';
import 'package:indigo_insights/views/insights/redemption/redemption_information.dart';
import 'package:indigo_insights/widgets/ii_asset_tabs.dart';
import 'package:indigo_insights/widgets/ii_card.dart';
import 'package:indigo_insights/widgets/ii_top_bar.dart';

class RedemptionInsights extends StatelessWidget {
  const RedemptionInsights({super.key, this.initialTab});

  final String? initialTab;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const IITopBar(title: 'Redemption'),
        Expanded(
          child: SelectionArea(
            child: IIAssetTabs(
              initialTabName: initialTab,
              tabContentBuilder: (asset) {
                final isDesktop =
                    MediaQuery.of(context).size.width >= 700;
                final rmrChart = IICard(
                  padding: EdgeInsets.zero,
                  child: RedeemableOverRmrsChart(asset),
                );
                final feeChart = IICard(
                  padding: EdgeInsets.zero,
                  child: RedemptionFeeBreakdownChart(asset.asset),
                );
                final avgChart = IICard(
                  padding: EdgeInsets.zero,
                  child: RedemptionAvgSizeChart(asset.asset),
                );
                final infoCard = IICard(
                  child: RedemptionInformation(asset.asset),
                );

                if (isDesktop) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(flex: 3, child: rmrChart),
                        const SizedBox(height: 16),
                        Expanded(
                          flex: 2,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(child: feeChart),
                              const SizedBox(width: 16),
                              Expanded(child: avgChart),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        infoCard,
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 260, child: rmrChart),
                      const SizedBox(height: 16),
                      SizedBox(height: 260, child: feeChart),
                      const SizedBox(height: 16),
                      SizedBox(height: 260, child: avgChart),
                      const SizedBox(height: 16),
                      infoCard,
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
