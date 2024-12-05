import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/models/cdps_stats.dart';
import 'package:indigo_insights/models/indigo_asset.dart';
import 'package:indigo_insights/providers/cdp_provider.dart';
import 'package:indigo_insights/theme/gradients.dart';
import 'package:indigo_insights/utils/loader.dart';
import 'package:indigo_insights/widgets/amount_date_chart.dart';

class CollateralHistoryChart extends HookConsumerWidget {
  const CollateralHistoryChart(this.indigoAsset, {super.key});
  final IndigoAsset indigoAsset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    getCollateralHistory(List<CdpsStats> cdpsStats) {
      final data = cdpsStats
          .groupFoldBy<DateTime, double>(
            (item) => DateTime(item.time.year, item.time.month, item.time.day),
            (a, b) =>
                (a ?? 0) > b.totalCollateral ? (a ?? 0) : b.totalCollateral,
          )
          .entries
          .map((entry) => AmountDateData(entry.key, entry.value))
          .toList();

      data.sortBy((d) => d.date);

      return data;
    }

    return ref.watch(cdpsStatsProvider(indigoAsset.asset)).when(
        data: (cdpsStats) {
          final collateralHistory = getCollateralHistory(cdpsStats);

          return AmountDateChart(
            title: "Collateral History",
            currency: indigoAsset.asset,
            labels: const ["Total Collateral"],
            data: [collateralHistory],
            colors: [getColorByAsset(indigoAsset.asset)],
            gradients: [getGradientByAsset(indigoAsset.asset)],
            minY: 0,
          );
        },
        error: (error, stackTrade) => Text(error.toString()),
        loading: () => const Loader());
  }
}
