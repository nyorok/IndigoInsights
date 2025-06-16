import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/models/asset_interest_rate.dart';
import 'package:indigo_insights/models/liquidity_pool_yield.dart';
import 'package:indigo_insights/providers/cdp_provider.dart';
import 'package:indigo_insights/providers/dex_yield_provider.dart';
import 'package:indigo_insights/providers/indigo_asset_provider.dart';
import 'package:indigo_insights/theme/color_scheme.dart';
import 'package:indigo_insights/utils/loader.dart';
import 'package:indigo_insights/views/insights/strategy/ada_farming_stable_pool/ada_farming_stable_pool_card.dart';
import 'package:indigo_insights/views/insights/strategy/ada_farming_stable_pool/ada_farming_stable_pool_description.dart';
import 'package:indigo_insights/widgets/financial_disclaimer.dart';

typedef StrategyData = ({
  String title,
  double strategyYield,
  double tradingFeesApr,
  double farmingApr,
  double interestRate,
  double rmr,
  double mcr,
  double liquidationRatio,
  double debtMintingFee,
});

final stablePoolFarmingStrategyProvider = FutureProvider<List<StrategyData>>((
  ref,
) async {
  final indigoAssets = await ref.watch(indigoAssetsProvider.future);
  final List<StrategyData> strategies = [];

  final assetInterestRates = await ref.watch(assetInterestRatesProvider.future);

  final Map<String, AssetInterestRate> lastInterestRatesMap = {};
  for (final ir in assetInterestRates) {
    if (!lastInterestRatesMap.containsKey(ir.asset) ||
        lastInterestRatesMap[ir.asset]!.slot < ir.slot) {
      lastInterestRatesMap[ir.asset] = ir;
    }
  }

  final dexYields = await ref
      .watch(dexYieldProvider.future)
      .then(
        (value) => value
            .where((e) => e.dex == Dex.minswapStableSwap)
            .where((e) => indigoAssets.any((ia) => e.hasAsset(ia.asset)))
            .toList(),
      );

  for (final e in dexYields) {
    final iAsset = indigoAssets.firstWhere((ia) => e.hasAsset(ia.asset));
    final interestRate =
        lastInterestRatesMap.values
            .firstWhereOrNull((ir) => e.hasAsset(ir.asset))
            ?.interestRate ??
        0.0;

    strategies.add((
      title: e.pair,
      strategyYield: e.tradingFeesApr + e.farmingApr - (interestRate * 100),
      tradingFeesApr: e.tradingFeesApr,
      farmingApr: e.farmingApr,
      interestRate: interestRate * 100,
      rmr: iAsset.rmr,
      mcr: iAsset.maintenanceRatio,
      liquidationRatio: iAsset.liquidationRatio,
      debtMintingFee: iAsset.debtMintingFee,
    ));
  }

  return strategies.sortedBy((a) => a.strategyYield).reversed.toList();
});

class StablePoolFarmingStrategyContent extends HookConsumerWidget {
  const StablePoolFarmingStrategyContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(stablePoolFarmingStrategyProvider)
        .when(
          data: (strategiesData) => SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  color: secondaryBackground.withAlpha(150),
                  child: const AdaFarmingStablePoolDescription(),
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
                                AdaFarmingStablePoolCard(
                                      title: strategyData.title,
                                      strategyYield: strategyData.strategyYield,
                                      tradingFeesApr:
                                          strategyData.tradingFeesApr,
                                      farmingApr: strategyData.farmingApr,
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
