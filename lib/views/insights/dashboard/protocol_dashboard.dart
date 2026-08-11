import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:indigo_insights/models/asset_status.dart';
import 'package:indigo_insights/models/indigo_asset.dart';
import 'package:indigo_insights/repositories/protocol_dashboard_repository.dart';
import 'package:indigo_insights/service_locator.dart';
import 'package:indigo_insights/theme/app_color_scheme.dart';
import 'package:indigo_insights/theme/app_text_styles.dart';
import 'package:indigo_insights/theme/gradients.dart';
import 'package:indigo_insights/utils/async_builder.dart';
import 'package:indigo_insights/utils/formatters.dart';
import 'package:indigo_insights/widgets/ii_card.dart';
import 'package:indigo_insights/widgets/ii_data_row.dart';
import 'package:indigo_insights/widgets/ii_kpi_strip.dart';
import 'package:indigo_insights/widgets/ii_top_bar.dart';
import 'package:indigo_insights/widgets/yield_sources.dart';

class ProtocolDashboard extends StatelessWidget {
  const ProtocolDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const IITopBar(title: 'Protocol Dashboard'),
        Expanded(
          child: AsyncBuilder(
            fetcher: () => sl<ProtocolDashboardRepository>().getDashboardData(),
            builder: (data) => _DashboardContent(data: data),
            errorBuilder: (error, retry) =>
                Center(child: Text(error.toString())),
          ),
        ),
      ],
    );
  }
}

// ── Content ───────────────────────────────────────────────────────────────────

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.data});
  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 700;

    return SelectionArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _KpiStrip(data: data),
            const SizedBox(height: 8),
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _TvlByAssetSection(data: data)),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 360,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ActivityCard(data: data),
                        const SizedBox(height: 8),
                        const TopYieldsCard(),
                      ],
                    ),
                  ),
                ],
              )
            else ...[
              _ActivityCard(data: data),
              const SizedBox(height: 16),
              const TopYieldsCard(),
              const SizedBox(height: 16),
              _TvlByAssetSection(data: data),
            ],
            _AssetHealthSection(data: data),
          ],
        ),
      ),
    );
  }
}

// ── KPI Strip ─────────────────────────────────────────────────────────────────

class _KpiStrip extends StatelessWidget {
  const _KpiStrip({required this.data});
  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);

    // Protocol TVL and CDP debt come from /api/v3/analytics/{tvl,loans}: the
    // per-asset `totalValueLocked` field adds raw ADA/NIGHT/USDCx amounts
    // together and can't be converted to a currency.
    final totalTvl = data.tvl.protocolUsd;
    final totalCdps = data.loanAnalytics.totalLoans;
    final indyPrice = data.indyPrice;
    final totalDebt = data.loanAnalytics.debtValueUsd;

    return IIKpiStrip(
      cells: [
        IIKpiCell(
          label: 'Protocol TVL',
          value: numberAbbreviatedFormatter(
            totalTvl,
            getAbbreviation(totalTvl),
          ),
          unit: 'USD',
        ),
        IIKpiCell(
          label: 'Active CDPs',
          value: numberFormatter(totalCdps, 0),
          unit: 'positions',
        ),
        IIKpiCell(
          label: 'INDY Price',
          value: numberFormatter(indyPrice, 4),
          unit: 'ADA',
        ),
        IIKpiCell(
          label: 'CDP Debt',
          value: numberAbbreviatedFormatter(
            totalDebt,
            getAbbreviation(totalDebt),
          ),
          unit: 'USD',
          valueColor: colors.primary,
        ),
      ],
    );
  }
}

// ── TVL by Asset (flat section) ───────────────────────────────────────────────

class _TvlByAssetSection extends StatelessWidget {
  const _TvlByAssetSection({required this.data});
  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    final styles = AppTextStyles.of(context);
    final colors = AppColorScheme.of(context);
    // USD collateral per iAsset — the only cross-collateral comparable figure.
    // PSM-minted iAssets are backed 1:1 by stablecoins held in the PSM rather
    // than by a CDP, so that value is stacked on as a separate segment.
    final minted = data.mintedByAsset;
    final psmUsd = <String, double>{
      for (final s in data.assetStatuses)
        s.asset: ((s.totalSupply - (minted[s.asset] ?? 0)) * s.usdPrice)
            .clamp(0.0, double.infinity),
    };

    final entries = data.loanAnalytics.collateralUsdByAsset.entries
        .map((e) => (asset: e.key, collateral: e.value, psm: psmUsd[e.key] ?? 0.0))
        .toList()
      ..sort((a, b) => (b.collateral + b.psm).compareTo(a.collateral + a.psm));
    final maxTvl = entries.isEmpty
        ? 1.0
        : entries
              .map((e) => e.collateral + e.psm)
              .reduce((a, b) => a > b ? a : b);
    final hasPsm = entries.any((e) => _hasPsm(e.psm, e.collateral + e.psm));

    return IICard(
      variant: IICardVariant.flat,
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Collateral by Asset',
                style: styles.sectionLabel.copyWith(color: colors.textMuted),
              ),
              if (hasPsm)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _psmShade(getColorByAsset('iUSD')),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'PSM',
                      style: styles.sectionLabel.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: entries.length * 34 + 8,
            child: _CollateralBarChart(
              entries: entries,
              maxTvl: maxTvl,
              colors: colors,
              styles: styles,
            ),
          ),
        ],
      ),
    );
  }
}

/// Darker shade of an iAsset colour, used for the PSM-backed segment.
Color _psmShade(Color base) => Color.lerp(base, Colors.black, 0.55)!;

/// The PSM share is derived by subtracting CDP mints from total supply, and the
/// two come from separate snapshots — so tiny values are timing noise, not PSM.
/// Only treat it as real once it is a meaningful share of the asset.
bool _hasPsm(double psm, double total) => psm > 1 && total > 0 && psm / total > 0.005;

typedef _CollateralEntry = ({String asset, double collateral, double psm});

/// Horizontal stacked bars (CDP collateral + PSM reserves) with fl_chart's
/// built-in touch tooltip carrying the breakdown.
class _CollateralBarChart extends StatelessWidget {
  const _CollateralBarChart({
    required this.entries,
    required this.maxTvl,
    required this.colors,
    required this.styles,
  });

  final List<_CollateralEntry> entries;
  final double maxTvl;
  final AppColorScheme colors;
  final AppTextStyles styles;

  @override
  Widget build(BuildContext context) {
    String usd(double v) =>
        '${numberAbbreviatedFormatter(v, getAbbreviation(v))} USD';

    return BarChart(
      BarChartData(
        // Rotate a quarter turn so the bars read horizontally, one per asset.
        rotationQuarterTurns: 1,
        maxY: maxTvl * 1.02,
        alignment: BarChartAlignment.spaceEvenly,
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= entries.length) return const SizedBox.shrink();
                final e = entries[i];
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    e.asset,
                    style: styles.bodySm.copyWith(color: colors.textPrimary),
                  ),
                );
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            // Default is 120px, which wraps each row onto two lines.
            maxContentWidth: 260,
            getTooltipColor: (_) => colors.surface,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final e = entries[group.x];
              final hasPsm = _hasPsm(e.psm, e.collateral + e.psm);
              final total = e.collateral + (hasPsm ? e.psm : 0.0);
              return BarTooltipItem(
                '${e.asset}\n',
                styles.bodySm.copyWith(
                  color: getColorByAsset(e.asset),
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: 'CDP collateral  ${usd(e.collateral)}',
                    style: styles.bodySm.copyWith(color: colors.textPrimary),
                  ),
                  if (hasPsm)
                    TextSpan(
                      // The dark bar shade is unreadable on the dark tooltip.
                      text: '\nPSM reserves  ${usd(e.psm)}',
                      style: styles.bodySm.copyWith(color: colors.textPrimary),
                    ),
                  if (hasPsm)
                    TextSpan(
                      text: '\nTotal  ${usd(total)}',
                      style: styles.bodySm.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        barGroups: entries.mapIndexed((i, e) {
          final color = getColorByAsset(e.asset);
          final hasPsm = _hasPsm(e.psm, e.collateral + e.psm);
          final total = e.collateral + (hasPsm ? e.psm : 0.0);
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: total,
                width: 10,
                borderRadius: BorderRadius.circular(4),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxTvl,
                  color: colors.surfaceRaised,
                ),
                rodStackItems: [
                  BarChartRodStackItem(0, e.collateral, color),
                  if (hasPsm)
                    BarChartRodStackItem(
                      e.collateral,
                      total,
                      _psmShade(color),
                    ),
                ],
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ── 24h Activity (Accent Panel) ───────────────────────────────────────────────

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.data});
  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final styles = AppTextStyles.of(context);
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(hours: 24));

    final liq24h = data.liquidations
        .where((l) => l.createdAt.isAfter(yesterday))
        .length;
    // Collateral can be ADA, NIGHT, USDC… — sum USD values, never raw amounts.
    final liqCollateralUsd24h = data.liquidations
        .where((l) => l.createdAt.isAfter(yesterday))
        .fold(0.0, (s, l) => s + l.collateralUsdValue);

    final stakeNow = data.stakeHistory.isNotEmpty
        ? data.stakeHistory.last.staked
        : 0.0;
    final stakeYday =
        data.stakeHistory
            .lastWhereOrNull((s) => s.date.isBefore(yesterday))
            ?.staked ??
        stakeNow;
    final stakeDelta = stakeNow - stakeYday;

    return IICard(
      variant: IICardVariant.accentPanel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '24h Activity',
            style: styles.cardTitle.copyWith(color: colors.primary),
          ),
          const SizedBox(height: 16),
          _ActivityRow(
            icon: Icons.flash_on,
            label: 'Liquidations',
            value: '$liq24h events',
            sub: '${numberFormatter(liqCollateralUsd24h, 0)} USD absorbed',
            valueColor: liq24h > 0 ? colors.error : colors.success,
            colors: colors,
            styles: styles,
          ),
          Divider(color: colors.primaryBorder, height: 20),
          _ActivityRow(
            icon: Icons.trending_up,
            label: 'INDY Staked (delta)',
            value:
                '${stakeDelta >= 0 ? '+' : ''}${numberFormatter(stakeDelta, 0)}',
            sub:
                'Total: ${numberAbbreviatedFormatter(stakeNow, getAbbreviation(stakeNow))} INDY',
            valueColor: stakeDelta >= 0 ? colors.success : colors.warning,
            colors: colors,
            styles: styles,
          ),
          Divider(color: colors.primaryBorder, height: 20),
          _ActivityRow(
            icon: Icons.account_balance,
            label: 'Total CDPs',
            value: numberFormatter(data.cdps.length, 0),
            sub: '${data.assetStatuses.length} active assets',
            valueColor: colors.textPrimary,
            colors: colors,
            styles: styles,
          ),
        ],
      ),
    ).animate().fade(duration: 600.ms);
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    required this.valueColor,
    required this.colors,
    required this.styles,
  });

  final IconData icon;
  final String label;
  final String value;
  final String sub;
  final Color valueColor;
  final AppColorScheme colors;
  final AppTextStyles styles;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: colors.primarySurface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: colors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: styles.bodySm.copyWith(color: colors.primary)),
              Text(
                value,
                style: styles.bodyMd.copyWith(
                  color: valueColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(sub, style: styles.bodySm.copyWith(color: colors.textMuted)),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Asset Health ──────────────────────────────────────────────────────────────

class _AssetHealthSection extends StatelessWidget {
  const _AssetHealthSection({required this.data});
  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 700;

    final cards = sortedByAsset(data.assetStatuses, (s) => s.asset).mapIndexed((
      i,
      status,
    ) {
      final pool = data.stabilityPools.firstWhereOrNull(
        (p) => p.asset == status.asset,
      );
      final assetCdps = data.cdps
          .where((c) => c.asset == status.asset)
          .toList();
      final totalMinted = assetCdps.fold(0.0, (s, c) => s + c.mintedAmount);
      final spCoverage = (pool != null && totalMinted > 0)
          ? pool.totalAmount / totalMinted
          : 0.0;

      // CR from USD collateral over USD CDP debt. `totalSupply` can exceed the
      // CDP debt because iAssets may also be minted through the PSM.
      final collateralUsd =
          data.loanAnalytics.collateralUsdByAsset[status.asset] ?? 0.0;
      final debtUsd = totalMinted * status.usdPrice;
      final collateralRatio = debtUsd > 0 ? collateralUsd / debtUsd * 100 : 0.0;

      return _AssetHealthCard(
        status: status,
        spCoverage: spCoverage,
        cdpCount: assetCdps.length,
        index: i,
        collateralRatio: collateralRatio,
        cdpMinted: totalMinted,
        indigoAsset: data.indigoAssets.firstWhereOrNull(
          (a) => a.asset == status.asset,
        ),
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        if (isDesktop)
          // Wrap instead of a single Row: the asset list grows over time
          // (7+ iAssets) and a fixed row overflows.
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 12.0;
              const minCardWidth = 220.0;
              final columns =
                  ((constraints.maxWidth + gap) / (minCardWidth + gap))
                      .floor()
                      .clamp(1, cards.length);
              final cardWidth =
                  (constraints.maxWidth - gap * (columns - 1)) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: cards
                    .map((card) => SizedBox(width: cardWidth, child: card))
                    .toList(),
              );
            },
          )
        else
          ...cards.map(
            (card) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: card,
            ),
          ),
      ],
    );
  }
}

class _AssetHealthCard extends StatelessWidget {
  const _AssetHealthCard({
    required this.status,
    required this.spCoverage,
    required this.cdpCount,
    required this.index,
    required this.collateralRatio,
    required this.cdpMinted,
    this.indigoAsset,
  });

  final AssetStatus status;
  final double spCoverage;
  final int cdpCount;
  final int index;

  /// USD collateral / USD CDP debt, in percent.
  final double collateralRatio;

  /// Amount minted through CDPs (excludes PSM mints).
  final double cdpMinted;

  final IndigoAsset? indigoAsset;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final styles = AppTextStyles.of(context);

    Color crColor(double cr) {
      final asset = indigoAsset;
      if (asset != null) {
        final mcr = asset.maintenanceRatio;
        final lr = asset.liquidationRatio;
        if (mcr != null && cr >= mcr + 20) return colors.success;
        if (mcr != null && cr >= mcr) return colors.warning;
        if (lr != null && cr >= lr) return colors.warning;
        if (mcr != null || lr != null) return colors.error;
      }
      // Fallback if IndigoAsset not available
      if (cr >= 200) return colors.success;
      if (cr >= 150) return colors.warning;
      return colors.error;
    }

    final crFraction = (collateralRatio / 300).clamp(0.0, 1.0);
    final spFraction = spCoverage.clamp(0.0, 1.0);
    final abbr = getAbbreviation(cdpMinted);
    // iUSD is also minted 1:1 against stablecoins in the PSM; that portion has
    // no CDP and no collateral ratio, so it is listed separately.
    final psmMinted = status.totalSupply - cdpMinted;

    return IICard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    status.asset,
                    style: styles.cardTitle.copyWith(color: colors.textPrimary),
                  ),
                  Text(
                    '$cdpCount CDPs',
                    style: styles.bodySm.copyWith(color: colors.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _HealthRow(
                label: 'System CR',
                value: '${collateralRatio.toStringAsFixed(1)}%',
                fraction: crFraction,
                color: crColor(collateralRatio),
              ),
              const SizedBox(height: 8),
              _HealthRow(
                label: 'SP Coverage',
                value: '${(spCoverage * 100).toStringAsFixed(1)}%',
                fraction: spFraction,
                color: spFraction >= 0.5 ? colors.success : colors.warning,
              ),
              const SizedBox(height: 8),
              IIDataRow(
                label: 'CDP Minted',
                value:
                    '${numberAbbreviatedFormatter(cdpMinted, abbr)} ${status.asset}',
                valueStyle: styles.monoSm,
              ),
              if (_hasPsm(psmMinted, status.totalSupply))
                IIDataRow(
                  label: 'PSM Minted',
                  value:
                      '${numberAbbreviatedFormatter(psmMinted, getAbbreviation(psmMinted))} ${status.asset}',
                  valueStyle: styles.monoSm.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
            ],
          ),
        )
        .animate()
        .slideX(
          begin: 0.2,
          duration: ((index + 2) * 100).ms,
          curve: Curves.easeOut,
        )
        .fade(duration: ((index + 2) * 100).ms);
  }
}

class _HealthRow extends StatelessWidget {
  const _HealthRow({
    required this.label,
    required this.value,
    required this.fraction,
    required this.color,
  });

  final String label;
  final String value;
  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final styles = AppTextStyles.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: styles.bodySm.copyWith(color: colors.textSecondary),
            ),
            Text(
              value,
              style: styles.monoSm.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction,
            backgroundColor: colors.surfaceRaised,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
