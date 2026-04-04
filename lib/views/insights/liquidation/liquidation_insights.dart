import 'package:flutter/material.dart';
import 'package:indigo_insights/views/insights/liquidation/cumulative_liquidations_chart.dart';
import 'package:indigo_insights/views/insights/liquidation/liquidation_information.dart';
import 'package:indigo_insights/views/insights/liquidation/liquidation_size_distribution_chart.dart';
import 'package:indigo_insights/widgets/ii_asset_tabs.dart';
import 'package:indigo_insights/widgets/ii_card.dart';
import 'package:indigo_insights/widgets/ii_top_bar.dart';

class LiquidationInsights extends StatelessWidget {
  const LiquidationInsights({super.key, this.initialTab});

  final String? initialTab;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const IITopBar(title: 'Liquidation'),
        Expanded(
          child: SelectionArea(
            child: IIAssetTabs(
              initialTabName: initialTab,
              tabContentBuilder: (asset) {
                final isDesktop =
                    MediaQuery.of(context).size.width >= 700;
                final cumChart = IICard(
                  padding: EdgeInsets.zero,
                  child: CumulativeLiquidationsChart(asset),
                );
                final sizeChart = IICard(
                  padding: EdgeInsets.zero,
                  child: LiquidationSizeDistributionChart(asset),
                );
                final freqChart = IICard(
                  padding: EdgeInsets.zero,
                  child: LiquidationFrequencyChart(asset),
                );
                final infoCard = IICard(
                  child: LiquidationInformation(indigoAsset: asset),
                );

                if (isDesktop) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(flex: 55, child: cumChart),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 45,
                                child: Column(
                                  children: [
                                    Expanded(child: sizeChart),
                                    const SizedBox(height: 16),
                                    Expanded(child: freqChart),
                                  ],
                                ),
                              ),
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
                      SizedBox(height: 280, child: cumChart),
                      const SizedBox(height: 16),
                      SizedBox(height: 260, child: sizeChart),
                      const SizedBox(height: 16),
                      SizedBox(height: 260, child: freqChart),
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
