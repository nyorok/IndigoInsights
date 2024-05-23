import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/models/redemption.dart';
import 'package:indigo_insights/theme/gradients.dart';
import 'package:indigo_insights/widgets/amount_date_chart.dart';

class RedemptionChart extends HookConsumerWidget {
  const RedemptionChart(this.redemptionsByAsset, {super.key});
  final Map<String, List<Redemption>> redemptionsByAsset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    getRedemptionData(List<Redemption> redemptions) {
      final data = redemptions
          .groupFoldBy<DateTime, double>(
            (item) => DateTime(
                item.createdAt.year, item.createdAt.month, item.createdAt.day),
            (a, b) => (a ?? 0) + b.lovelacesReturned,
          )
          .entries
          .map((entry) => AmountDateData(entry.key, entry.value))
          .toList();
      data.sortBy((d) => d.date);
      final firstDate = data.first.date;
      data.add(AmountDateData(firstDate.add(const Duration(days: -1)), 0));
      data.sortBy((d) => d.date);

      return data;
    }

    final dataByAsset = redemptionsByAsset.entries
        .map((entry) => (
              label: entry.key,
              color: getColorByAsset(entry.key),
              gradient: getGradientByAsset(entry.key),
              data: getRedemptionData(entry.value)
            ))
        .sortedBy((e) => e.label);

    final redemptionsData = getRedemptionData(redemptionsByAsset.values
        .expand((redemptions) => redemptions)
        .toList());

    return AmountDateChart(
      title: "Staking Rewards",
      currency: "ADA",
      labels: ['Total', ...dataByAsset.map((a) => a.label)],
      data: [redemptionsData, ...dataByAsset.map((a) => a.data)],
      colors: [Colors.white, ...dataByAsset.map((a) => a.color)],
      gradients: [whiteGradient, ...dataByAsset.map((a) => a.gradient)],
    );
  }
}
