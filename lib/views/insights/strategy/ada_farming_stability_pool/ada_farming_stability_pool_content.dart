import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/models/asset_interest_rate.dart';
import 'package:indigo_insights/providers/asset_price_provider.dart';
import 'package:indigo_insights/providers/cdp_provider.dart';
import 'package:indigo_insights/providers/incentives_per_epoch_provider.dart';
import 'package:indigo_insights/providers/indigo_asset_provider.dart';
import 'package:indigo_insights/providers/indy_price_provider.dart';
import 'package:indigo_insights/providers/stability_pool_provider.dart';
import 'package:indigo_insights/theme/color_scheme.dart';
import 'package:indigo_insights/utils/loader.dart';
import 'package:indigo_insights/views/insights/strategy/ada_farming_stability_pool/ada_farming_stability_pool_card.dart';
import 'package:indigo_insights/views/insights/strategy/ada_farming_stability_pool/ada_farming_stability_pool_description.dart';
import 'package:indigo_insights/widgets/financial_disclaimer.dart';

typedef StrategyData = ({
  String title,
  double strategyYield,
  double poolYield,
  double interestRate,
  double rmr,
  double mcr,
  double liquidationRatio,
  double debtMintingFee,
});

final stabilityPoolFarmingStrategyProvider = FutureProvider<List<StrategyData>>(
  (ref) async {
    final List<StrategyData> strategies = [];
    final assetPrices = await ref.watch(assetPricesProvider.future);
    final stabilityPools = await ref.watch(stabilityPoolProvider.future);
    final indyPrice = await ref.watch(indyPriceProvider.future);
    final indigoAssets = await ref.watch(indigoAssetsProvider.future);
    final assetInterestRates = await ref.watch(
      assetInterestRatesProvider.future,
    );

    final Map<String, AssetInterestRate> lastInterestRatesMap = {};
    for (final ir in assetInterestRates) {
      if (!lastInterestRatesMap.containsKey(ir.asset) ||
          lastInterestRatesMap[ir.asset]!.slot < ir.slot) {
        lastInterestRatesMap[ir.asset] = ir;
      }
    }

    strategies.addAll(
      stabilityPools.map((e) {
        final iAsset = indigoAssets.firstWhere((ia) => ia.asset == e.asset);
        final stabilityPoolApr =
            (ref.read(stabilityPoolIncentivesPerYearProvider(e.asset)) *
                indyPrice) /
            (e.totalAmount *
                assetPrices.firstWhere((ap) => ap.asset == e.asset).price);

        final interestRate = lastInterestRatesMap[e.asset]?.interestRate ?? 0.0;

        return (
          title: e.asset,
          strategyYield: (stabilityPoolApr - interestRate) * 100,
          poolYield: stabilityPoolApr * 100,
          interestRate: interestRate * 100,
          rmr: iAsset.rmr,
          mcr: iAsset.maintenanceRatio,
          liquidationRatio: iAsset.liquidationRatio,
          debtMintingFee: iAsset.debtMintingFee,
        );
      }),
    );

    return strategies.sortedBy((a) => a.strategyYield).reversed.toList();
  },
);

class StabilityPoolFarmingStrategyContent extends HookConsumerWidget {
  const StabilityPoolFarmingStrategyContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(stabilityPoolFarmingStrategyProvider)
        .when(
          data: (strategiesData) => SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  color: secondaryBackground.withAlpha(150),
                  child: const AdaFarmingStabilityPoolDescription(),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final double spacing = 8.0;
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
                            child:
                                AdaFarmingStabilityPoolCard(
                                      title: strategyData.title,
                                      strategyYield: strategyData.strategyYield,
                                      poolYield: strategyData.poolYield,
                                      interestRate: strategyData.interestRate,
                                      redemptionMarginRatio: strategyData.rmr,
                                      maintenanceRatio: strategyData.mcr,
                                      liquidationRatio:
                                          strategyData.liquidationRatio,
                                      debtMintingFee:
                                          strategyData.debtMintingFee,
                                    )
                                    .animate()
                                    .slideX(
                                      duration: 300.ms,
                                      curve: Curves.easeInOut,
                                    )
                                    .fadeIn(
                                      duration: 600.ms,
                                      curve: Curves.easeInOut,
                                    ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
                const FinancialDisclaimer(),
              ],
            ),
          ),
          loading: () => const Loader(),
          error: (error, stackTrace) => Text(error.toString()),
        );
  }
}
