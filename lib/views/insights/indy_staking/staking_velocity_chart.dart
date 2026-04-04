import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:indigo_insights/models/stake_history.dart';
import 'package:indigo_insights/repositories/stake_history_repository.dart';
import 'package:indigo_insights/service_locator.dart';
import 'package:indigo_insights/theme/color_scheme.dart';
import 'package:indigo_insights/utils/async_builder.dart';
import 'package:indigo_insights/widgets/amount_date_chart.dart';

class StakingVelocityChart extends StatelessWidget {
  const StakingVelocityChart({super.key});

  @override
  Widget build(BuildContext context) {
    return AsyncBuilder(
      fetcher: () => sl<StakeHistoryRepository>().getHistory(),
      builder: (history) {
        if (history.length < 2) {
          return const Center(child: Text('Not enough data.'));
        }
        final sorted = history.sortedBy((s) => s.date);
        return _VelocityChart(history: sorted);
      },
      errorBuilder: (error, retry) => Text(error.toString()),
    );
  }
}

class _VelocityChart extends StatelessWidget {
  final List<StakeHistory> history;
  const _VelocityChart({required this.history});

  List<AmountDateData> _buildDailyDeltas() {
    // Group by day, take last entry per day
    final byDay = history.groupFoldBy<DateTime, StakeHistory>(
      (s) => DateTime(s.date.year, s.date.month, s.date.day),
      (prev, curr) => (prev == null || curr.date.isAfter(prev.date))
          ? curr
          : prev,
    );

    final days = byDay.keys.toList()..sort();
    final result = <AmountDateData>[];

    for (int i = 1; i < days.length; i++) {
      final prev = byDay[days[i - 1]]!.staked;
      final curr = byDay[days[i]]!.staked;
      result.add(AmountDateData(days[i], curr - prev));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final deltas = _buildDailyDeltas();
    if (deltas.isEmpty) return const SizedBox.shrink();

    final positiveData = deltas.map((d) => AmountDateData(d.date, d.amount.clamp(0, double.infinity))).toList();
    final negativeData = deltas.map((d) => AmountDateData(d.date, d.amount.clamp(-double.infinity, 0))).toList();

    return AmountDateChart(
      title: 'Staking Velocity (Daily Delta)',
      data: [positiveData, negativeData],
      colors: [onSuccess, primaryRed],
      gradients: [
        LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [onSuccess.withValues(alpha: 0.4), onSuccess.withValues(alpha: 0.05)],
        ),
        LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [primaryRed.withValues(alpha: 0.4), primaryRed.withValues(alpha: 0.05)],
        ),
      ],
      labels: ['Staked', 'Unstaked'],
      currency: 'INDY',
    ).animate().fade(duration: 500.ms);
  }
}
