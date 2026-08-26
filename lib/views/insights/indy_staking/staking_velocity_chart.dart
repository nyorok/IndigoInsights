import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:indigo_insights/models/stake_history.dart';
import 'package:indigo_insights/repositories/stake_history_repository.dart';
import 'package:indigo_insights/service_locator.dart';
import 'package:indigo_insights/theme/app_color_scheme.dart';
import 'package:indigo_insights/theme/app_text_styles.dart';
import 'package:indigo_insights/theme/color_scheme.dart';
import 'package:indigo_insights/utils/async_builder.dart';
import 'package:indigo_insights/utils/formatters.dart';
import 'package:intl/intl.dart' as intl;
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
        return _TrendChart(history: sorted);
      },
      errorBuilder: (error, retry) => Text(error.toString()),
    );
  }
}

class _TrendChart extends StatelessWidget {
  final List<StakeHistory> history;
  const _TrendChart({required this.history});

  static const _windowDays = 14;

  List<AmountDateData> _buildSmoothedTrend() {
    final byDay = history.groupFoldBy<DateTime, StakeHistory>(
      (s) => DateTime(s.date.year, s.date.month, s.date.day),
      (prev, curr) =>
          (prev == null || curr.date.isAfter(prev.date)) ? curr : prev,
    );

    final days = byDay.keys.toList()..sort();

    final deltas = <double>[];
    final deltaDates = <DateTime>[];
    for (int i = 1; i < days.length; i++) {
      final prev = byDay[days[i - 1]]!.staked;
      final curr = byDay[days[i]]!.staked;
      deltas.add(curr - prev);
      deltaDates.add(days[i]);
    }

    final result = <AmountDateData>[];
    for (int i = 0; i < deltas.length; i++) {
      final start = (i - _windowDays + 1).clamp(0, i);
      final window = deltas.sublist(start, i + 1);
      final avg = window.reduce((a, b) => a + b) / window.length;
      result.add(AmountDateData(deltaDates[i], avg));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final trend = _buildSmoothedTrend();
    if (trend.isEmpty) return const SizedBox.shrink();

    final appColors = AppColorScheme.of(context);
    final styles = AppTextStyles.of(context);

    final spots = trend
        .map((d) => FlSpot(
              d.date.millisecondsSinceEpoch.toDouble(),
              d.amount,
            ))
        .toList();

    final maxAbs = trend.map((d) => d.amount.abs()).reduce((a, b) => a > b ? a : b);
    final abbreviation = getAbbreviation(maxAbs);

    final minX = trend.first.date.millisecondsSinceEpoch.toDouble();
    final maxX = trend.last.date.millisecondsSinceEpoch.toDouble();
    final totalDays = trend.last.date.difference(trend.first.date).inDays;
    final dateIntervalDays = (totalDays / 6).ceil();

    DateTime? previousDateLabel;

    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(top: 8, left: 30, right: 16),
          child: Row(
            children: [
              Text('Staking Trends (14-Day Average)', style: styles.cardTitle)
                  .animate()
                  .fade(duration: 300.ms),
              const Spacer(),
              Text('Net Staking', style: styles.bodyMd.copyWith(color: onSuccess, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              Text('Net Unstaking', style: styles.bodyMd.copyWith(color: primaryRed, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        Expanded(
          child: LineChart(
            LineChartData(
              minX: minX,
              maxX: maxX,
              minY: -maxAbs * 1.2,
              maxY: maxAbs * 1.2,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.3,
                  color: Colors.white.withValues(alpha: 0.85),
                  barWidth: 1.5,
                  dotData: const FlDotData(show: false),
                  // Green fill: below the line where value > 0, capped at y=0
                  belowBarData: BarAreaData(
                    show: true,
                    cutOffY: 0,
                    applyCutOffY: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        onSuccess.withValues(alpha: 0.55),
                        onSuccess.withValues(alpha: 0.05),
                      ],
                    ),
                  ),
                  // Red fill: above the line where value < 0, capped at y=0
                  aboveBarData: BarAreaData(
                    show: true,
                    cutOffY: 0,
                    applyCutOffY: true,
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        primaryRed.withValues(alpha: 0.55),
                        primaryRed.withValues(alpha: 0.05),
                      ],
                    ),
                  ),
                ),
              ],
              gridData: const FlGridData(show: true),
              borderData: FlBorderData(show: true),
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: 0,
                    color: appColors.textMuted.withValues(alpha: 0.5),
                    strokeWidth: 1,
                    dashArray: [6, 4],
                  ),
                ],
              ),
              titlesData: FlTitlesData(
                topTitles: AxisTitles(
                  sideTitles: SideTitles(reservedSize: 15, showTitles: true, getTitlesWidget: (v, m) => const Text('')),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(reservedSize: 30, showTitles: true, getTitlesWidget: (v, m) => const Text('')),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    interval: Duration(days: dateIntervalDays).inMilliseconds.toDouble(),
                    showTitles: true,
                    reservedSize: 36,
                    getTitlesWidget: (value, meta) {
                      final date = DateTime.fromMillisecondsSinceEpoch(value.toInt()).toUtc();
                      final day = DateTime(date.year, date.month, date.day);
                      if (previousDateLabel != null &&
                          day.difference(previousDateLabel!).inDays.abs() < dateIntervalDays) {
                        previousDateLabel = day;
                        return const SizedBox();
                      }
                      previousDateLabel = day;
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          '${day.month}/${day.year.toString().substring(2)}',
                          style: styles.monoSm.copyWith(color: appColors.textMuted),
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    reservedSize: 72,
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value == meta.min || value == meta.max) return const SizedBox();
                      return Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          '${numberAbbreviated(value, abbreviation).toStringAsFixed(1)}${abbreviation?.name ?? ''}',
                          style: styles.monoSm.copyWith(color: appColors.textMuted),
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  getTooltipColor: (_) => appColors.surface,
                  getTooltipItems: (spots) => spots.map((s) {
                    final date = DateTime.fromMillisecondsSinceEpoch(s.x.toInt());
                    final isPositive = s.y >= 0;
                    return LineTooltipItem(
                      '${intl.DateFormat('yyyy/MM/dd').format(date)}\n${isPositive ? '+' : ''}${numberFormatter(s.y, 0)} INDY',
                      styles.bodySm.copyWith(
                        color: isPositive ? onSuccess : primaryRed,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }).toList(),
                ),
                handleBuiltInTouches: true,
              ),
            ),
          ).animate().fade(duration: 500.ms, curve: Curves.easeInOut),
        ),
      ],
    );
  }
}
