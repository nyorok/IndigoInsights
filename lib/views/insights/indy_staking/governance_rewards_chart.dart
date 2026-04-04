import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:indigo_insights/models/liquidation.dart';
import 'package:indigo_insights/models/redemption.dart';
import 'package:indigo_insights/repositories/indy_price_repository.dart';
import 'package:indigo_insights/repositories/liquidation_repository.dart';
import 'package:indigo_insights/repositories/redemption_repository.dart';
import 'package:indigo_insights/repositories/stake_history_repository.dart';
import 'package:indigo_insights/service_locator.dart';
import 'package:indigo_insights/theme/app_color_scheme.dart';
import 'package:indigo_insights/theme/app_text_styles.dart';
import 'package:indigo_insights/theme/gradients.dart';
import 'package:indigo_insights/utils/async_builder.dart';
import 'package:indigo_insights/utils/formatters.dart';
import 'package:indigo_insights/widgets/amount_date_chart.dart';

typedef _GovRewardsData = ({
  List<Liquidation> liquidations,
  double indyPrice,
  double totalStaked,
});

class GovernanceRewardsChart extends StatelessWidget {
  const GovernanceRewardsChart({super.key});

  @override
  Widget build(BuildContext context) {
    return AsyncBuilder<_GovRewardsData>(
      fetcher: () async {
        final results = await Future.wait([
          sl<LiquidationRepository>().getLiquidations(),
          sl<IndyPriceRepository>().getPrice(),
          sl<StakeHistoryRepository>().getHistory(),
        ]);
        final history = results[2] as List;
        return (
          liquidations: results[0] as List<Liquidation>,
          indyPrice: results[1] as double,
          totalStaked: history.isNotEmpty
              ? (history.last as dynamic).staked as double
              : 0.0,
        );
      },
      builder: (data) => _GovernanceContent(data: data),
      errorBuilder: (error, retry) => Text(error.toString()),
    );
  }
}

class _GovernanceContent extends StatelessWidget {
  final _GovRewardsData data;
  const _GovernanceContent({required this.data});

  List<AmountDateData> _buildCumulativeGovernanceRewards() {
    final sorted = data.liquidations.sortedBy((l) => l.createdAt);
    final byDay = <DateTime, double>{};
    for (final liq in sorted) {
      final day = DateTime(
          liq.createdAt.year, liq.createdAt.month, liq.createdAt.day);
      byDay[day] = (byDay[day] ?? 0) + liq.collateralAbsorbed * 0.02;
    }
    final days = byDay.keys.toList()..sort();
    double cumulative = 0;
    return days.map((day) {
      cumulative += byDay[day]!;
      return AmountDateData(day, cumulative);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final styles = AppTextStyles.of(context);
    final govRewardData = _buildCumulativeGovernanceRewards();
    if (govRewardData.isEmpty) return const SizedBox.shrink();

    final totalGovAda = govRewardData.last.amount;
    final adaAbbr = getAbbreviation(totalGovAda);
    final stakedAbbr = getAbbreviation(data.totalStaked);

    final successGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        colors.success.withValues(alpha: 0.7),
        colors.success.withValues(alpha: 0.2),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 24,
            runSpacing: 8,
            children: [
              _GovernanceStat(
                'Total Gov. ADA (all time)',
                '${numberAbbreviatedFormatter(totalGovAda, adaAbbr)} ADA',
                greenGradient,
                styles: styles,
              ),
              _GovernanceStat(
                'Total INDY Staked',
                '${numberAbbreviatedFormatter(data.totalStaked, stakedAbbr)} INDY',
                indigoGradient,
                styles: styles,
              ),
              _GovernanceStat(
                'INDY Price',
                '${numberFormatter(data.indyPrice, 4)} ADA',
                greyGradient,
                styles: styles,
              ),
            ],
          ),
        ),
        Expanded(
          child: AmountDateChart(
            title: 'Cumulative Governance ADA Rewards',
            data: [govRewardData],
            colors: [colors.success],
            gradients: [successGradient],
            labels: ['Gov. ADA'],
            currency: 'ADA',
          ).animate().fade(duration: 500.ms),
        ),
      ],
    );
  }
}

class _GovernanceStat extends StatelessWidget {
  final String label;
  final String value;
  final Gradient gradient;
  final AppTextStyles styles;
  const _GovernanceStat(this.label, this.value, this.gradient,
      {required this.styles});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: styles.sectionLabel
                  .copyWith(color: Colors.white.withValues(alpha: 0.8))),
          Text(value,
              style: styles.bodySm.copyWith(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ─── Fee Revenue Timeline ─────────────────────────────────────────────────────

class FeeRevenueChart extends StatelessWidget {
  const FeeRevenueChart({super.key});

  @override
  Widget build(BuildContext context) {
    return AsyncBuilder<
        ({List<Liquidation> liquidations, List<Redemption> redemptionsAll})>(
      fetcher: () async {
        final assets = ['iUSD', 'iBTC', 'iETH', 'iSOL'];
        final results = await Future.wait([
          sl<LiquidationRepository>().getLiquidations(),
          ...assets
              .map((a) => sl<RedemptionRepository>().getRedemptionsForAsset(a)),
        ]);
        final allRedemptions = assets
            .mapIndexed((i, _) => results[i + 1] as List<Redemption>)
            .expand((r) => r)
            .toList();
        return (
          liquidations: results[0] as List<Liquidation>,
          redemptionsAll: allRedemptions,
        );
      },
      builder: (data) => _FeeRevenueContent(data: data),
      errorBuilder: (error, retry) => Text(error.toString()),
    );
  }
}

class _FeeRevenueContent extends StatelessWidget {
  final ({List<Liquidation> liquidations, List<Redemption> redemptionsAll}) data;
  const _FeeRevenueContent({required this.data});

  List<AmountDateData> _buildLiqFeeData() {
    final byDay = <DateTime, double>{};
    for (final l in data.liquidations) {
      final day =
          DateTime(l.createdAt.year, l.createdAt.month, l.createdAt.day);
      byDay[day] = (byDay[day] ?? 0) + l.collateralAbsorbed * 0.02;
    }
    final days = byDay.keys.toList()..sort();
    double cum = 0;
    return days.map((d) {
      cum += byDay[d]!;
      return AmountDateData(d, cum);
    }).toList();
  }

  List<AmountDateData> _buildRedemptionFeeData() {
    final byDay = <DateTime, double>{};
    for (final r in data.redemptionsAll) {
      final day =
          DateTime(r.createdAt.year, r.createdAt.month, r.createdAt.day);
      byDay[day] = (byDay[day] ?? 0) +
          r.processingFeeLovelaces +
          r.reimbursementFeeLovelaces;
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
    final liqFees = _buildLiqFeeData();
    final redemptionFees = _buildRedemptionFeeData();

    if (liqFees.isEmpty && redemptionFees.isEmpty) {
      return const Center(child: Text('No fee data available.'));
    }

    final allData = [
      if (liqFees.isNotEmpty) liqFees,
      if (redemptionFees.isNotEmpty) redemptionFees,
    ];

    final successGrad = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        colors.success.withValues(alpha: 0.7),
        colors.success.withValues(alpha: 0.2),
      ],
    );

    return AmountDateChart(
      title: 'Cumulative Protocol Fee Revenue',
      data: allData,
      colors: [
        if (liqFees.isNotEmpty) colors.success,
        if (redemptionFees.isNotEmpty) colors.primary,
      ],
      gradients: [
        if (liqFees.isNotEmpty) successGrad,
        if (redemptionFees.isNotEmpty) blueGradient,
      ],
      labels: [
        if (liqFees.isNotEmpty) 'Liquidation Gov.',
        if (redemptionFees.isNotEmpty) 'Redemption Fees',
      ],
      currency: 'ADA',
    ).animate().fade(duration: 500.ms);
  }
}
