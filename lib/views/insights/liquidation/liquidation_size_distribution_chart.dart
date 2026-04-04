import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:indigo_insights/models/liquidation.dart';
import 'package:indigo_insights/models/indigo_asset.dart';
import 'package:indigo_insights/repositories/liquidation_repository.dart';
import 'package:indigo_insights/service_locator.dart';
import 'package:indigo_insights/theme/color_scheme.dart';
import 'package:indigo_insights/utils/async_builder.dart';
import 'package:indigo_insights/theme/app_text_styles.dart';
import 'package:indigo_insights/widgets/amount_date_chart.dart';

class LiquidationSizeDistributionChart extends StatelessWidget {
  final IndigoAsset indigoAsset;
  const LiquidationSizeDistributionChart(this.indigoAsset, {super.key});

  @override
  Widget build(BuildContext context) {
    return AsyncBuilder<List<Liquidation>>(
      fetcher: () =>
          sl<LiquidationRepository>().getLiquidationsForAsset(indigoAsset.asset),
      builder: (liquidations) {
        if (liquidations.isEmpty) {
          return const Center(child: Text('No liquidations.'));
        }
        return _SizeDistContent(liquidations: liquidations);
      },
      errorBuilder: (error, retry) => Text(error.toString()),
    );
  }
}

class _SizeDistContent extends StatelessWidget {
  final List<Liquidation> liquidations;
  const _SizeDistContent({required this.liquidations});

  static const _buckets = [
    (label: '<1k', min: 0.0, max: 1000.0),
    (label: '1k–5k', min: 1000.0, max: 5000.0),
    (label: '5k–20k', min: 5000.0, max: 20000.0),
    (label: '20k–100k', min: 20000.0, max: 100000.0),
    (label: '>100k', min: 100000.0, max: double.infinity),
  ];

  static const _colors = [
    Colors.teal,
    Colors.blueAccent,
    Colors.amber,
    Colors.orange,
    Color(0xFFFF3344),
  ];

  @override
  Widget build(BuildContext context) {
    final counts = List.filled(_buckets.length, 0);
    for (final l in liquidations) {
      for (int i = 0; i < _buckets.length; i++) {
        if (l.collateralAbsorbed >= _buckets[i].min &&
            l.collateralAbsorbed < _buckets[i].max) {
          counts[i]++;
          break;
        }
      }
    }

    final maxCount = counts.reduce((a, b) => a > b ? a : b).toDouble();

    final groups = counts.mapIndexed((i, c) => BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: c.toDouble(),
              color: _colors[i],
              width: 30,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        )).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Liquidation Size Distribution',
              style: AppTextStyles.of(context).cardTitle),
          const SizedBox(height: 8),
          Expanded(
          child: BarChart(
            BarChartData(
              maxY: maxCount * 1.2,
              barGroups: groups,
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: true),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    getTitlesWidget: (v, meta) => Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Text(v.toInt().toString(),
                          style: const TextStyle(fontSize: 9)),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (v, meta) => SideTitleWidget(
                      meta: meta,
                      child: Text(
                        _buckets[v.toInt()].label,
                        style: TextStyle(
                            fontSize: 9, color: _colors[v.toInt()]),
                      ),
                    ),
                  ),
                ),
              ),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) =>
                      Theme.of(context).colorScheme.surface,
                  getTooltipItem: (group, gi, rod, ri) {
                    return BarTooltipItem(
                      '${_buckets[group.x].label}\n${rod.toY.toInt()} events',
                      TextStyle(color: _colors[group.x], fontSize: 11),
                    );
                  },
                ),
              ),
            ),
          ).animate().fade(duration: 500.ms),
        ),
        ],
      ),
    );
  }
}

// ─── Time Between Liquidations ────────────────────────────────────────────────

class LiquidationFrequencyChart extends StatelessWidget {
  final IndigoAsset indigoAsset;
  const LiquidationFrequencyChart(this.indigoAsset, {super.key});

  @override
  Widget build(BuildContext context) {
    return AsyncBuilder<List<Liquidation>>(
      fetcher: () =>
          sl<LiquidationRepository>().getLiquidationsForAsset(indigoAsset.asset),
      builder: (liquidations) {
        if (liquidations.length < 2) {
          return const Center(child: Text('Not enough data.'));
        }
        return _FrequencyContent(liquidations: liquidations);
      },
      errorBuilder: (error, retry) => Text(error.toString()),
    );
  }
}

class _FrequencyContent extends StatelessWidget {
  final List<Liquidation> liquidations;
  const _FrequencyContent({required this.liquidations});

  @override
  Widget build(BuildContext context) {
    final sorted = liquidations.sortedBy((l) => l.createdAt);

    // Daily liquidation count as AmountDateData
    final byDay = <DateTime, int>{};
    for (final l in sorted) {
      final day = DateTime(l.createdAt.year, l.createdAt.month, l.createdAt.day);
      byDay[day] = (byDay[day] ?? 0) + 1;
    }
    final days = byDay.keys.toList()..sort();
    final dailyCounts = days
        .map((d) => AmountDateData(d, byDay[d]!.toDouble()))
        .toList();

    if (dailyCounts.isEmpty) return const SizedBox.shrink();

    return AmountDateChart(
      title: 'Daily Liquidation Events',
      data: [dailyCounts],
      colors: [primaryRed],
      gradients: [
        LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [primaryRed.withValues(alpha: 0.4), primaryRed.withValues(alpha: 0.05)],
        ),
      ],
      labels: ['Liquidations'],
      currency: 'events',
    ).animate().fade(duration: 500.ms);
  }
}
