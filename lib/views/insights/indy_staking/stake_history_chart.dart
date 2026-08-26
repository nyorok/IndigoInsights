import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';
import 'package:indigo_insights/models/stake_history.dart';
import 'package:indigo_insights/repositories/stake_history_repository.dart';
import 'package:indigo_insights/service_locator.dart';
import 'package:indigo_insights/theme/gradients.dart';
import 'package:indigo_insights/utils/async_builder.dart';
import 'package:indigo_insights/widgets/amount_date_chart.dart';

class StakeHistoryChart extends StatelessWidget {
  const StakeHistoryChart({super.key});

  List<AmountDateData> _getStakeHistoriesData(List<StakeHistory> stakeHistories) {
    final data = stakeHistories
        .sortedBy((item) => item.date)
        .groupFoldBy<DateTime, double>(
          (item) => DateTime(item.date.year, item.date.month, item.date.day),
          (_, b) => b.staked, // tS is a total snapshot, keep the last (most recent) per day
        )
        .entries
        .map((entry) => AmountDateData(entry.key, entry.value))
        .toList()
      ..sortBy((d) => d.date);

    final firstDate = data.first.date;
    data.add(AmountDateData(firstDate.add(const Duration(days: -1)), 0));
    data.sortBy((d) => d.date);

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return AsyncBuilder(
      fetcher: () => sl<StakeHistoryRepository>().getHistory(),
      builder: (stakeHistories) {
        final stakeHistoryData = _getStakeHistoriesData(stakeHistories);

        return AmountDateChart(
          title: 'Staking History',
          currency: 'INDY',
          labels: const ['Staked'],
          data: [stakeHistoryData],
          colors: const [Colors.deepPurpleAccent],
          gradients: [indigoGradient],
          maxY: stakeHistoryData.last.amount * 1.2,
        );
      },
      errorBuilder: (error, retry) => Text(error.toString()),
    );
  }
}
