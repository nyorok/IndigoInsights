import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/models/stake_history.dart';
import 'package:indigo_insights/providers/stake_history_provider.dart';
import 'package:indigo_insights/theme/gradients.dart';
import 'package:indigo_insights/utils/loader.dart';
import 'package:indigo_insights/widgets/amount_date_chart.dart';

class StakeHistoryChart extends HookConsumerWidget {
  const StakeHistoryChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    getStakeHistoriesData(List<StakeHistory> stakeHistories) {
      final data = stakeHistories
          .groupFoldBy<DateTime, double>(
            (item) => DateTime(item.date.year, item.date.month, item.date.day),
            (a, b) => (a ?? 0) + b.staked,
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

    return ref.watch(stakeHistoriesProvider).when(
        data: (accountsUnclaimedRewards) {
          final stakeHistoryData =
              getStakeHistoriesData(accountsUnclaimedRewards);

          return AmountDateChart(
            title: "Staking History",
            currency: "INDY",
            labels: const ["Staked"],
            data: [stakeHistoryData],
            colors: const [Colors.deepPurpleAccent],
            gradients: const [indigoGradient],
            maxY: stakeHistoryData.last.amount * 1.2,
          );
        },
        error: (error, stackTrade) => Text(error.toString()),
        loading: () => const Loader());
  }
}
