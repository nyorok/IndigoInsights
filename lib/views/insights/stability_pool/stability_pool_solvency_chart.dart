import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/models/cdp.dart';
import 'package:indigo_insights/models/indigo_asset.dart';
import 'package:indigo_insights/providers/asset_price_provider.dart';
import 'package:indigo_insights/providers/cdp_provider.dart';
import 'package:indigo_insights/providers/stability_pool_provider.dart';
import 'package:indigo_insights/theme/gradients.dart';
import 'package:indigo_insights/utils/loader.dart';
import 'package:indigo_insights/widgets/amount_percentage_chart.dart';

final stabilityPoolSolvencyDataProvider =
    FutureProvider.family<List<AmountPercentageData>, IndigoAsset>((
      ref,
      indigoAsset,
    ) async {
      final assetPrice = await ref
          .watch(assetPricesProvider.future)
          .then((ap) => ap.firstWhere((ap) => ap.asset == indigoAsset.asset));

      final stabilityPool = await ref
          .watch(stabilityPoolProvider.future)
          .then((sp) => sp.firstWhere((ap) => ap.asset == indigoAsset.asset));

      calculatePriceChangeToLiquidate(Cdp cdp) {
        final collateralInAsset = cdp.collateralAmount / assetPrice.price;
        final collateralRatio = collateralInAsset / cdp.mintedAmount;
        final lr = indigoAsset.liquidationRatio / 100;

        if (lr > collateralRatio) {
          throw Exception(
            'Liquidation ratio is greater than collateral ratio!',
          );
        }

        return 1.00 - (lr / collateralRatio);
      }

      final cdps = await ref
          .watch(cdpsProvider.future)
          .then((cdps) => cdps.where((cdp) => cdp.asset == indigoAsset.asset));

      final percentToLiqAndCollateralData = cdps
          .map(
            (cdp) => (
              minted: cdp.mintedAmount,
              percentToLiquidate: (calculatePriceChangeToLiquidate(cdp) * 100)
                  .round(),
            ),
          )
          .groupFoldBy<int, double>(
            (item) => item.percentToLiquidate,
            (a, b) => (a ?? 0) + b.minted,
          )
          .entries
          .map(
            (entry) =>
                (percentToLiq: entry.key.toDouble() / 100, minted: entry.value),
          )
          .toList();

      percentToLiqAndCollateralData.sort(
        (a, b) => a.percentToLiq.compareTo(b.percentToLiq),
      );

      double spAmount = stabilityPool.totalAmount;
      final amountPercentageData = percentToLiqAndCollateralData.map((item) {
        spAmount -= item.minted;
        return AmountPercentageData(item.percentToLiq, spAmount);
      }).toList();

      return normalizeAmountPercentageData(
        amountPercentageData,
        60,
        stabilityPool.totalAmount,
      );
    });

class StabilityPoolSolvencyChart extends HookConsumerWidget {
  const StabilityPoolSolvencyChart({super.key, required this.indigoAsset});

  final IndigoAsset indigoAsset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(stabilityPoolSolvencyDataProvider(indigoAsset))
        .when(
          data: (stabilityPoolSolvencyData) {
            return AmountPercentageChart(
              currency: indigoAsset.asset,
              labels: const ['Balance'],
              data: [stabilityPoolSolvencyData],
              colors: const [Colors.blueAccent],
              gradients: [greenBlueGradient],
            );
          },
          error: (error, stackTrade) => Text(error.toString()),
          loading: () => const Loader(),
        );
  }
}
