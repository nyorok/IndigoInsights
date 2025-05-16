import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/models/cdps_stats.dart';
import 'package:indigo_insights/models/indigo_asset.dart';
import 'package:indigo_insights/providers/cdp_provider.dart';
import 'package:indigo_insights/theme/gradients.dart';
import 'package:indigo_insights/utils/loader.dart';
import 'package:indigo_insights/widgets/amount_date_chart.dart';

class MintedSupplyHistoryChart extends HookConsumerWidget {
  const MintedSupplyHistoryChart(this.indigoAsset, {super.key});
  final IndigoAsset indigoAsset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    getMintedSupplyHistory(List<CdpsStats> cdpsStats) {
      final data = cdpsStats
          .groupFoldBy<DateTime, double>(
            (item) => DateTime(item.time.year, item.time.month, item.time.day),
            (a, b) => (a ?? 0) > b.totalMinted ? (a ?? 0) : b.totalMinted,
          )
          .entries
          .map((entry) => AmountDateData(entry.key, entry.value))
          .toList();

      data.sortBy((d) => d.date);

      return data;
    }

    return ref.watch(cdpsStatsProvider(indigoAsset.asset)).when(
        data: (cdpsStats) {
          final mintedSupplyHistory = getMintedSupplyHistory(cdpsStats);

          return AmountDateChart(
            title: "Minted Supply History",
            currency: indigoAsset.asset,
            labels: const ["Minted Supply"],
            data: [mintedSupplyHistory],
            colors: [getColorByAsset(indigoAsset.asset)],
            gradients: [getGradientByAsset(indigoAsset.asset)],
            minY: 0,
          );
        },
        error: (error, stackTrade) => Text(error.toString()),
        loading: () => const Loader());
  }
}
