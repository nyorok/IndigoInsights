import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/models/cdp.dart';
import 'package:indigo_insights/models/indigo_asset.dart';
import 'package:indigo_insights/providers/asset_price_provider.dart';
import 'package:indigo_insights/providers/cdp_provider.dart';
import 'package:indigo_insights/theme/gradients.dart';
import 'package:indigo_insights/widgets/percentage_amount_chart.dart';

double calculateRedeemableAmount(Cdp cdp, double rmr, double adaPrice) {
  final ratio = cdp.collateralAmount / (adaPrice * cdp.mintedAmount);
  if (rmr <= ratio) return 0;

  return ((-cdp.collateralAmount / adaPrice) + rmr * cdp.mintedAmount) /
      (rmr - 1);
}

final cdpsAndPriceProvider = FutureProvider.family<
    ({
      List<Cdp> cdps,
      double adaPrice,
    }),
    String>((ref, asset) async {
  final cdps = await ref
      .watch(cdpsProvider.future)
      .then((value) => value.where((e) => e.asset == asset).toList());

  final price = await ref
      .watch(assetPricesProvider.future)
      .then((value) => value.firstWhere((e) => e.asset == asset).price);

  return (cdps: cdps, adaPrice: price);
});

class RedeemableOverRmrsChart extends HookConsumerWidget {
  const RedeemableOverRmrsChart(this.indigoAsset, {super.key});
  final IndigoAsset indigoAsset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rmrs = List.generate(164, (index) => indigoAsset.rmr + index * 5.0);

    getRedeemableOverRmrsData(List<Cdp> cdps, double adaPrice) {
      final redeemablePerCdp = cdps
          .map((e) => rmrs.map((rmr) => PercentageAmountData(
              rmr, calculateRedeemableAmount(e, rmr / 100, adaPrice))))
          .expand((e) => e)
          .where((e) => e.amount.abs() > 0)
          .toList();

      final data = redeemablePerCdp
          .groupFoldBy<double, double>(
            (item) => item.percentage,
            (a, b) => (a ?? 0) + b.amount,
          )
          .entries
          .map((entry) => PercentageAmountData(entry.key, entry.value))
          .toList();

      data.sort((a, b) => a.percentage.compareTo(b.percentage));

      return data;
    }

    return ref.watch(cdpsAndPriceProvider(indigoAsset.asset)).when(
          data: (data) {
            final cdps = data.cdps;
            final adaPrice = data.adaPrice;

            return PercentageAmountChart(
              title: "Redeemable over RMRs (${indigoAsset.rmr}%)",
              currency: indigoAsset.asset,
              labels: [indigoAsset.asset],
              mintedSupply: cdps.map((e) => e.mintedAmount).sum,
              data: [getRedeemableOverRmrsData(cdps, adaPrice)],
              colors: [getColorByAsset(indigoAsset.asset)],
              gradients: [getGradientByAsset(indigoAsset.asset)],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Error: $error')),
        );
  }
}
