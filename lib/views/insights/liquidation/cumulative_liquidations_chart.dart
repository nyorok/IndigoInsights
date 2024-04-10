import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/models/liquidation.dart';
import 'package:indigo_insights/providers/liquidation_provider.dart';
import 'package:indigo_insights/theme/color_scheme.dart';
import 'package:indigo_insights/theme/gradients.dart';
import 'package:indigo_insights/utils/loader.dart';
import 'package:indigo_insights/widgets/amount_date_chart.dart';

class CumulativeLiquidationsChart extends HookConsumerWidget {
  const CumulativeLiquidationsChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    getCumulativeLiquidationsData(
        {required List<Liquidation> data, String? asset}) {
      final liquidations =
          data.where((l) => asset == null || l.asset == asset).toList();

      liquidations.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      double cumulativeSum = 0.0;
      return liquidations
          .groupFoldBy<DateTime, double>(
            (item) => DateTime(
                item.createdAt.year, item.createdAt.month, item.createdAt.day),
            (a, b) => (a ?? 0) + b.collateralAbsorbed,
          )
          .entries
          .map((entry) => AmountDateData(entry.key, entry.value))
          .map((liq) {
        cumulativeSum += liq.amount;

        return AmountDateData(liq.date, cumulativeSum);
      }).toList();
    }

    return ref.watch(liquidationProvider).when(
        data: (liquidations) {
          liquidations.sortBy((l) => l.createdAt);
          final startDate = liquidations.first.createdAt;
          final endDate = liquidations.last.createdAt;

          return AmountDateChart(
            title: "Cumulative Liquidations",
            currency: "ADA",
            labels: const ["Total", "iBTC", "iETH", "iUSD"],
            data: [
              normalizeAmountDateData(
                  getCumulativeLiquidationsData(data: liquidations),
                  startDate,
                  endDate),
              normalizeAmountDateData(
                  getCumulativeLiquidationsData(
                      data: liquidations, asset: "iBTC"),
                  startDate,
                  endDate),
              normalizeAmountDateData(
                  getCumulativeLiquidationsData(
                      data: liquidations, asset: "iETH"),
                  startDate,
                  endDate),
              normalizeAmountDateData(
                  getCumulativeLiquidationsData(
                      data: liquidations, asset: "iUSD"),
                  startDate,
                  endDate),
            ],
            colors: [
              Colors.white,
              secondaryRed,
              Colors.blueGrey.shade700,
              Colors.blue.shade700,
            ],
            gradients: [
              whiteGradient,
              orangeTransparentGradient,
              greyTransparentGradient,
              blueTransparentGradient,
            ],
          );
        },
        error: (error, stackTrade) => Text(error.toString()),
        loading: () => const Loader());
  }
}
