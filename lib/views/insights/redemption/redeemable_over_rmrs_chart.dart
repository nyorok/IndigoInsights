import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/models/cdp.dart';
import 'package:indigo_insights/theme/gradients.dart';
import 'package:indigo_insights/widgets/percentage_amount_chart.dart';

double calculateRedeemableAmount(Cdp cdp, double rmr, double adaPrice) {
  final ratio = cdp.collateralAmount / (adaPrice * cdp.mintedAmount);
  if (rmr <= ratio) return 0;

  return ((-cdp.collateralAmount / adaPrice) + rmr * cdp.mintedAmount) /
      (rmr - 1);
}

class RedeemableOverRmrsChart extends HookConsumerWidget {
  const RedeemableOverRmrsChart(this.iUsdCdps, this.adaPrice, {super.key});
  final List<Cdp> iUsdCdps;
  final double adaPrice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rmrs = List.generate(164, (index) => 185.0 + index * 5.0);

    getRedeemableOverRmrsData(List<Cdp> cdps) {
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

    return PercentageAmountChart(
      title: "Redeemable iUSD over RMRs",
      currency: "iUSD",
      labels: const ['iUSD'],
      mintedSupply: iUsdCdps.map((e) => e.mintedAmount).sum,
      data: [getRedeemableOverRmrsData(iUsdCdps)],
      colors: [getColorByAsset('iUSD')],
      gradients: [getGradientByAsset('iUSD')],
    );
  }
}
