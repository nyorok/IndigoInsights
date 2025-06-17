import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/models/asset_interest_rate.dart';
import 'package:indigo_insights/providers/asset_price_provider.dart';
import 'package:indigo_insights/providers/cdp_provider.dart';
import 'package:indigo_insights/providers/indigo_asset_provider.dart';
import 'package:indigo_insights/theme/color_scheme.dart';
import 'package:indigo_insights/utils/loader.dart';
import 'package:indigo_insights/views/insights/strategy/ada_double_leverage_above_mr/ada_double_leverage_above_mr_card.dart';
import 'package:indigo_insights/views/insights/strategy/ada_double_leverage_above_mr/ada_double_leverage_above_mr_description.dart';
import 'package:indigo_insights/widgets/financial_disclaimer.dart';
import 'package:indigo_insights/widgets/slider_selector.dart';

typedef LeverageData = ({
  String asset,
  double interestRate,
  double redemptionMarginRatio,
  double maintenanceRatio,
  double liquidationRatio,
  double assetPrice,
  double debtMintingFee,
});

final adaDoubleLeverageAboveMrProvider = FutureProvider<List<LeverageData>>((
  ref,
) async {
  final indigoAssets = await ref.watch(indigoAssetsProvider.future);
  final assetInterestRates = await ref.watch(assetInterestRatesProvider.future);
  final assetPrices = await ref.watch(assetPricesProvider.future);

  final Map<String, AssetInterestRate> lastInterestRatesMap = {};
  for (final ir in assetInterestRates) {
    if (!lastInterestRatesMap.containsKey(ir.asset) ||
        lastInterestRatesMap[ir.asset]!.slot < ir.slot) {
      lastInterestRatesMap[ir.asset] = ir;
    }
  }

  final List<LeverageData> leverages = [];

  for (final iAsset in indigoAssets) {
    final interestRate =
        lastInterestRatesMap[iAsset.asset]?.interestRate ?? 0.0;
    final currentAssetPrice = assetPrices
        .firstWhere((ap) => ap.asset == iAsset.asset)
        .price;

    leverages.add((
      asset: iAsset.asset,
      interestRate: interestRate * 100,
      redemptionMarginRatio: iAsset.rmr,
      maintenanceRatio: iAsset.maintenanceRatio,
      liquidationRatio: iAsset.liquidationRatio,
      assetPrice: currentAssetPrice,
      debtMintingFee: iAsset.debtMintingFee,
    ));
  }

  return leverages.sortedBy((e) => e.asset).toList();
});

class AdaDoubleLeverageAboveMrContent extends HookConsumerWidget {
  const AdaDoubleLeverageAboveMrContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(adaDoubleLeverageAboveMrProvider)
        .when(
          data: (leveragesData) {
            final minCr = leveragesData.map((e) => e.maintenanceRatio).min;
            final maxCr = 500.0;
            final collateralRatio = useState(minCr);

            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    color: secondaryBackground.withAlpha(150),
                    child: const AdaDoubleLeverageAboveMrDescription(),
                  ),
                  SliderSelector(
                    initialValue: minCr,
                    minValue: minCr,
                    maxValue: maxCr,
                    label: 'Min: ${minCr.toStringAsFixed(0)}% (MCR) | Range',
                    unit: '%',
                    onChanged: (value) {
                      collateralRatio.value = value;
                    },
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
                          children: leveragesData.map((data) {
                            return SizedBox(
                              width: itemWidth,
                              child:
                                  AdaDoubleLeverageAboveMrCard(
                                        asset: data.asset,
                                        interestRate: data.interestRate,
                                        redemptionMarginRatio:
                                            data.redemptionMarginRatio,
                                        maintenanceRatio: data.maintenanceRatio,
                                        liquidationRatio: data.liquidationRatio,
                                        assetPrice: data.assetPrice,
                                        debtMintingFee: data.debtMintingFee,
                                        collateralRatio:
                                            collateralRatio.value >
                                                data.maintenanceRatio
                                            ? collateralRatio.value
                                            : data.maintenanceRatio,
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
            );
          },
          loading: () => const Loader(),
          error: (error, stackTrace) => Text(error.toString()),
        );
  }
}
