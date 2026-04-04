import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:indigo_insights/models/redemption.dart';
import 'package:indigo_insights/repositories/redemption_repository.dart';
import 'package:indigo_insights/service_locator.dart';
import 'package:indigo_insights/theme/app_color_scheme.dart';
import 'package:indigo_insights/theme/app_text_styles.dart';
import 'package:indigo_insights/theme/gradients.dart';
import 'package:indigo_insights/utils/async_builder.dart';
import 'package:indigo_insights/utils/formatters.dart';
import 'package:indigo_insights/widgets/amount_date_chart.dart';

class RedemptionFeeBreakdownChart extends StatelessWidget {
  final String asset;
  const RedemptionFeeBreakdownChart(this.asset, {super.key});

  @override
  Widget build(BuildContext context) {
    return AsyncBuilder<List<Redemption>>(
      fetcher: () => sl<RedemptionRepository>().getRedemptionsForAsset(asset),
      builder: (redemptions) {
        if (redemptions.isEmpty) {
          return const Center(child: Text('No redemption data.'));
        }
        return _FeeBreakdownContent(redemptions: redemptions);
      },
      errorBuilder: (error, retry) => Text(error.toString()),
    );
  }
}

class _FeeBreakdownContent extends StatelessWidget {
  final List<Redemption> redemptions;
  const _FeeBreakdownContent({required this.redemptions});

  List<AmountDateData> _buildCumProcessingFees() {
    final sorted = redemptions.sortedBy((r) => r.createdAt);
    final byDay = <DateTime, double>{};
    for (final r in sorted) {
      final day =
          DateTime(r.createdAt.year, r.createdAt.month, r.createdAt.day);
      byDay[day] = (byDay[day] ?? 0) + r.processingFeeLovelaces;
    }
    final days = byDay.keys.toList()..sort();
    double cum = 0;
    return days.map((d) {
      cum += byDay[d]!;
      return AmountDateData(d, cum);
    }).toList();
  }

  List<AmountDateData> _buildCumReimbursementFees() {
    final sorted = redemptions.sortedBy((r) => r.createdAt);
    final byDay = <DateTime, double>{};
    for (final r in sorted) {
      final day =
          DateTime(r.createdAt.year, r.createdAt.month, r.createdAt.day);
      byDay[day] = (byDay[day] ?? 0) + r.reimbursementFeeLovelaces;
    }
    final days = byDay.keys.toList()..sort();
    double cum = 0;
    return days.map((d) {
      cum += byDay[d]!;
      return AmountDateData(d, cum);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final processingFees = _buildCumProcessingFees();
    final reimbursementFees = _buildCumReimbursementFees();

    final totalProcessing =
        redemptions.fold(0.0, (s, r) => s + r.processingFeeLovelaces);
    final totalReimbursement =
        redemptions.fold(0.0, (s, r) => s + r.reimbursementFeeLovelaces);
    final totalFees = totalProcessing + totalReimbursement;
    final processAbbr = getAbbreviation(totalFees);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 20,
            runSpacing: 8,
            children: [
              _FeeStat(
                'Processing Fees',
                '${numberAbbreviatedFormatter(totalProcessing, processAbbr)} ADA',
                colors.primary,
              ),
              _FeeStat(
                'Reimbursement Fees',
                '${numberAbbreviatedFormatter(totalReimbursement, processAbbr)} ADA',
                colors.success,
              ),
              _FeeStat(
                'Total',
                '${numberAbbreviatedFormatter(totalFees, processAbbr)} ADA',
                colors.textPrimary,
              ),
            ],
          ),
        ),
        Expanded(
          child: AmountDateChart(
            title: 'Cumulative Redemption Fees',
            data: [processingFees, reimbursementFees],
            colors: [colors.primary, colors.success],
            gradients: [blueGradient, greyGradient],
            labels: ['Processing', 'Reimbursement'],
            currency: 'ADA',
          ).animate().fade(duration: 500.ms),
        ),
      ],
    );
  }
}

class _FeeStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _FeeStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final styles = AppTextStyles.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: styles.sectionLabel.copyWith(color: colors.textMuted)),
        Text(
          value,
          style: styles.bodySm.copyWith(
              color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// ─── Average Redemption Size Trend ───────────────────────────────────────────

class RedemptionAvgSizeChart extends StatelessWidget {
  final String asset;
  const RedemptionAvgSizeChart(this.asset, {super.key});

  @override
  Widget build(BuildContext context) {
    return AsyncBuilder<List<Redemption>>(
      fetcher: () => sl<RedemptionRepository>().getRedemptionsForAsset(asset),
      builder: (redemptions) {
        if (redemptions.length < 7) {
          return const Center(child: Text('Not enough data.'));
        }
        return _AvgSizeContent(redemptions: redemptions);
      },
      errorBuilder: (error, retry) => Text(error.toString()),
    );
  }
}

class _AvgSizeContent extends StatelessWidget {
  final List<Redemption> redemptions;
  const _AvgSizeContent({required this.redemptions});

  List<AmountDateData> _buildRollingAvg() {
    final sorted = redemptions.sortedBy((r) => r.createdAt);
    final byDay = <DateTime, List<double>>{};
    for (final r in sorted) {
      final day =
          DateTime(r.createdAt.year, r.createdAt.month, r.createdAt.day);
      byDay.putIfAbsent(day, () => []).add(r.redeemedAmount);
    }
    final days = byDay.keys.toList()..sort();
    final dailyAvgs = days.map((d) {
      final amounts = byDay[d]!;
      final avg = amounts.reduce((a, b) => a + b) / amounts.length;
      return AmountDateData(d, avg);
    }).toList();

    const window = 7;
    return List.generate(dailyAvgs.length, (i) {
      final start = (i - window + 1).clamp(0, i);
      final slice = dailyAvgs.sublist(start, i + 1);
      final avg =
          slice.map((d) => d.amount).reduce((a, b) => a + b) / slice.length;
      return AmountDateData(dailyAvgs[i].date, avg);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final rollingAvg = _buildRollingAvg();
    return AmountDateChart(
      title: '7-Day Avg Redemption Size',
      data: [rollingAvg],
      colors: [colors.success],
      gradients: [greyGradient],
      labels: ['Avg Size'],
      currency: 'iAsset',
    ).animate().fade(duration: 500.ms);
  }
}
