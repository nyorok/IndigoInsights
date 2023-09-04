import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/models/indigo_asset.dart';
import 'package:indigo_insights/providers/asset_status_provider.dart';
import 'package:indigo_insights/providers/stability_pool_provider.dart';
import 'package:indigo_insights/providers/sundae_swap/sundae_swap_asset_pool_provider.dart';
import 'package:indigo_insights/providers/vy_finance/vy_finance_asset_pool_provider.dart';
import 'package:indigo_insights/utils/formatters.dart';
import 'package:indigo_insights/utils/loader.dart';
import 'package:indigo_insights/utils/page_title.dart';
import 'package:indigo_insights/widgets/distribution_pie_chart.dart';

final assetMarketDistributionProvider = FutureProvider.family<
    ({
      double totalSupply,
      double spTotalAmount,
      double sundaeSwapTvl,
      double vyFinanceTvl
    }),
    IndigoAsset>((ref, indigoAsset) async {
  final assetTotalSupply = await ref.watch(assetStatusProvider.future).then(
      (value) =>
          value.firstWhere((e) => e.asset == indigoAsset.asset).totalSupply);

  final spTotalAmount = await ref.watch(stabilityPoolProvider.future).then(
      (value) =>
          value.firstWhere((e) => e.asset == indigoAsset.asset).totalAmount);

  final sundaeSwapTvl = await ref
      .watch(sundaeSwapAssetPoolProvider(indigoAsset).future)
      .then((value) => value.pools
          .map((e) => e.assetA == indigoAsset.asset ? e.quantityA : e.quantityB)
          .sum);

  final vyFinanceTvl = await ref
      .watch(vyFinanceAssetPoolProvider(indigoAsset).future)
      .then((value) => value
          .map((e) => e.assetA == indigoAsset.asset ? e.quantityA : e.quantityB)
          .sum);

  return (
    totalSupply: assetTotalSupply,
    spTotalAmount: spTotalAmount,
    sundaeSwapTvl: sundaeSwapTvl,
    vyFinanceTvl: vyFinanceTvl
  );
});

class IndigoAssetMarketDistributionPieChart extends HookConsumerWidget {
  const IndigoAssetMarketDistributionPieChart(
      {super.key, required this.indigoAsset});
  final IndigoAsset indigoAsset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final marketPair = ref.watch(marketPairProvider);
    // final assetPrices = ref.watch(assetPricesProvider);
    // final adaPrice = ref.watch(adaPriceProvider);

    // getAdaPrice() => adaPrice.asData?.value ?? 1;
    // getAssetPrice() =>
    //     assetPrices.asData?.value.firstWhere((a) => a.asset == asset).price ??
    //     1;

    getMarketsData(double totalSupply, double spTotalAmount,
        double sundaeSwapTvl, double vyFinanceTvl) {
      final othersAmount =
          totalSupply - spTotalAmount - sundaeSwapTvl - vyFinanceTvl;

      final data =
          List<({String title, double value, String touchedInfo})>.from([
        (
          title:
              "Others ${numberFormatter(othersAmount / totalSupply * 100, 2)}%",
          value: othersAmount / totalSupply,
          touchedInfo:
              'Others: ${numberFormatter(othersAmount, 2)} ${indigoAsset.asset}',
        ),
        (
          title:
              "Stability Pool: ${numberFormatter(spTotalAmount / totalSupply * 100, 2)}%",
          value: spTotalAmount / totalSupply,
          touchedInfo:
              '${numberFormatter(spTotalAmount, 2)} ${indigoAsset.asset}',
        ),
        (
          title:
              "SundaeSwap LP: ${numberFormatter(sundaeSwapTvl / totalSupply * 100, 2)}%",
          value: sundaeSwapTvl / totalSupply,
          touchedInfo:
              '${numberFormatter(sundaeSwapTvl, 2)} ${indigoAsset.asset}',
        ),
        (
          title:
              "VyFi LP: ${numberFormatter(vyFinanceTvl / totalSupply * 100, 2)}%",
          value: vyFinanceTvl / totalSupply,
          touchedInfo:
              '${numberFormatter(vyFinanceTvl, 2)} ${indigoAsset.asset}',
        )
      ]);

      return data;
    }

    return ref.watch(assetMarketDistributionProvider(indigoAsset)).when(
        data: (market) {
          final marketData = getMarketsData(market.totalSupply,
              market.spTotalAmount, market.sundaeSwapTvl, market.vyFinanceTvl);
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
                          title: "Market Distribution (${indigoAsset.asset})"),
                      Text(
                          "Total Supply: ${numberFormatter(market.totalSupply, 2)} ${indigoAsset.asset}")
                    ],
                  ),
                ),
              ),
              Expanded(
                child: DistributionPieChartWidget(
                  pieValues: marketData,
                  colorRange: generateColorRange(const Color(0xFFa500e1),
                      const Color(0xFF5839eb), marketData.length),
                ),
              ),
            ],
          );
        },
        error: (error, stackTrade) => Text(error.toString()),
        loading: () => const Loader());
  }
}
