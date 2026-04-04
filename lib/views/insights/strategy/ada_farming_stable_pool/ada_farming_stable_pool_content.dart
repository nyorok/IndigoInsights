import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:indigo_insights/repositories/strategy_repository.dart';
import 'package:indigo_insights/service_locator.dart';
import 'package:indigo_insights/theme/app_color_scheme.dart';
import 'package:indigo_insights/utils/async_builder.dart';
import 'package:indigo_insights/views/insights/strategy/ada_farming_stable_pool/ada_farming_stable_pool_card.dart';
import 'package:indigo_insights/views/insights/strategy/ada_farming_stable_pool/ada_farming_stable_pool_description.dart';
import 'package:indigo_insights/widgets/ii_disclaimer.dart';

class StablePoolFarmingStrategyContent extends StatelessWidget {
  const StablePoolFarmingStrategyContent({super.key});

  @override
  Widget build(BuildContext context) {
    return AsyncBuilder(
      fetcher: () => sl<StrategyRepository>().getStablePoolFarmingData(),
      builder: (strategiesData) => SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: AppColorScheme.of(context).surfaceRaised,
              child: const AdaFarmingStablePoolDescription(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const double spacing = 8.0;
                  int crossAxisCount = 1;
                  if (constraints.maxWidth > 1200) {
                    crossAxisCount = 4;
                  } else if (constraints.maxWidth > 800) {
                    crossAxisCount = 3;
                  } else if (constraints.maxWidth > 500) {
                    crossAxisCount = 2;
                  }

                  final double itemWidth =
                      (constraints.maxWidth -
                          (crossAxisCount - 1) * spacing) /
                      crossAxisCount;

                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: strategiesData.map((strategyData) {
                      return SizedBox(
                        width: itemWidth,
                        child: AdaFarmingStablePoolCard(
                          title: strategyData.title,
                          strategyYield: strategyData.strategyYield,
                          tradingFeesApr: strategyData.tradingFeesApr,
                          farmingApr: strategyData.farmingApr,
                          interestRate: strategyData.interestRate,
                          redemptionMarginRatio: strategyData.rmr,
                          maintenanceRatio: strategyData.mcr,
                          liquidationRatio: strategyData.liquidationRatio,
                          debtMintingFee: strategyData.debtMintingFee,
                        )
                            .animate()
                            .slideX(duration: 300.ms, curve: Curves.easeInOut)
                            .fadeIn(duration: 600.ms, curve: Curves.easeInOut),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            const IIDisclaimer(),
          ],
        ),
      ),
      errorBuilder: (error, retry) => Text(error.toString()),
    );
  }
}
