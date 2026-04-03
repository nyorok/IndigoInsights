import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:indigo_insights/models/indigo_asset.dart';
import 'package:indigo_insights/models/liquidation.dart';
import 'package:indigo_insights/repositories/liquidation_repository.dart';
import 'package:indigo_insights/service_locator.dart';
import 'package:indigo_insights/theme/gradients.dart';
import 'package:indigo_insights/utils/async_builder.dart';
import 'package:indigo_insights/widgets/amount_date_chart.dart';

class CumulativeLiquidationsChart extends StatelessWidget {
  const CumulativeLiquidationsChart(this.indigoAsset, {super.key});

  final IndigoAsset indigoAsset;

  List<AmountDateData> _getCumulativeLiquidationsData(List<Liquidation> data) {
    final liquidations = data.where((l) => l.asset == indigoAsset.asset).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    double cumulativeSum = 0.0;
    final liqData = liquidations
        .groupFoldBy<DateTime, double>(
          (item) =>
              DateTime(item.createdAt.year, item.createdAt.month, item.createdAt.day),
          (a, b) => (a ?? 0) + b.collateralAbsorbed,
        )
        .entries
        .map((entry) => AmountDateData(entry.key, entry.value))
        .map((liq) {
          cumulativeSum += liq.amount;
          return AmountDateData(liq.date, cumulativeSum);
        })
        .toList()
      ..sortBy((d) => d.date);

    final firstDate = liqData.first.date;
    liqData.add(AmountDateData(firstDate.add(const Duration(days: -1)), 0));
    liqData.sortBy((d) => d.date);

    return liqData;
  }

  @override
  Widget build(BuildContext context) {
    return AsyncBuilder(
      fetcher: () => sl<LiquidationRepository>().getLiquidations(),
      builder: (liquidations) {
        liquidations.sortBy((l) => l.createdAt);
        final startDate = liquidations.first.createdAt.add(const Duration(days: -1));
        final endDate = liquidations.last.createdAt.add(const Duration(days: -1));

        return AmountDateChart(
          title: 'Cumulative Liquidations',
          currency: 'ADA',
          labels: [indigoAsset.asset],
          data: [
            normalizeAmountDateData(
              _getCumulativeLiquidationsData(liquidations),
              startDate,
              endDate,
            ),
          ],
          colors: [getColorByAsset(indigoAsset.asset)],
          gradients: [getGradientByAsset(indigoAsset.asset)],
        );
      },
      errorBuilder: (error, retry) => Text(error.toString()),
    );
  }
}
