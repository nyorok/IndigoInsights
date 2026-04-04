import 'package:collection/collection.dart';
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
import 'package:indigo_insights/widgets/ii_section_header.dart';
import 'package:indigo_insights/widgets/ii_top_bar.dart';

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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _KpiStrip(data: data),
            const SizedBox(height: 16),
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _TvlByAssetSection(data: data)),
                  const SizedBox(width: 16),
                  SizedBox(width: 300, child: _ActivityCard(data: data)),
                ],
              )
            else ...[
              _ActivityCard(data: data),
              const SizedBox(height: 16),
              _TvlByAssetSection(data: data),
            ],
            const SizedBox(height: 24),
            _AssetHealthSection(data: data),
            const SizedBox(height: 24),
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

    final totalTvl = data.assetStatuses.fold(0.0, (s, a) => s + a.totalValueLocked);
    final totalCdps = data.cdps.length;
    final indyPrice = data.indyPrice;
    final totalMktCap =
        data.assetStatuses.fold(0.0, (s, a) => s + a.marketCap);

    return IIKpiStrip(
      cells: [
        IIKpiCell(
          label: 'Total TVL',
          value: numberAbbreviatedFormatter(totalTvl, getAbbreviation(totalTvl)),
          unit: 'ADA',
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
          label: 'iAsset Market Cap',
          value: numberAbbreviatedFormatter(
            totalMktCap,
            getAbbreviation(totalMktCap),
          ),
          unit: 'ADA',
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
    final statuses = data.assetStatuses;
    final maxTvl = statuses.isEmpty
        ? 1.0
        : statuses.map((s) => s.totalValueLocked).reduce((a, b) => a > b ? a : b);

    return IICard(
      variant: IICardVariant.flat,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TVL by Asset',
            style: styles.sectionLabel.copyWith(color: colors.textMuted),
          ),
          const SizedBox(height: 12),
          ...statuses.mapIndexed(
            (i, s) => _TvlBar(
              asset: s.asset,
              tvl: s.totalValueLocked,
              maxTvl: maxTvl,
              index: i,
            ),
          ),
        ],
      ),
    );
  }
}

class _TvlBar extends StatelessWidget {
  const _TvlBar({
    required this.asset,
    required this.tvl,
    required this.maxTvl,
    required this.index,
  });

  final String asset;
  final double tvl;
  final double maxTvl;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final styles = AppTextStyles.of(context);
    final fraction = maxTvl > 0 ? (tvl / maxTvl).clamp(0.0, 1.0) : 0.0;
    final color = getColorByAsset(asset);
    final abbr = getAbbreviation(tvl);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                asset,
                style: styles.bodyMd.copyWith(color: color),
              ),
              Text(
                '${numberAbbreviatedFormatter(tvl, abbr)} ADA',
                style: styles.monoSm.copyWith(color: colors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LayoutBuilder(
            builder: (ctx, constraints) => ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Stack(
                children: [
                  Container(
                    height: 8,
                    width: constraints.maxWidth,
                    color: colors.surfaceRaised,
                  ),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 400 + index * 80),
                    curve: Curves.easeOut,
                    height: 8,
                    width: constraints.maxWidth * fraction,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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

    final liq24h =
        data.liquidations.where((l) => l.createdAt.isAfter(yesterday)).length;
    final liqCollateral24h = data.liquidations
        .where((l) => l.createdAt.isAfter(yesterday))
        .fold(0.0, (s, l) => s + l.collateralAbsorbed);

    final stakeNow =
        data.stakeHistory.isNotEmpty ? data.stakeHistory.last.staked : 0.0;
    final stakeYday = data.stakeHistory
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
            sub: '${numberFormatter(liqCollateral24h, 0)} ADA absorbed',
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
              Text(
                label,
                style: styles.bodySm.copyWith(color: colors.primary),
              ),
              Text(
                value,
                style: styles.bodyMd.copyWith(
                  color: valueColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                sub,
                style: styles.bodySm.copyWith(color: colors.textMuted),
              ),
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

    final cards = data.assetStatuses.mapIndexed((i, status) {
      final pool = data.stabilityPools
          .firstWhereOrNull((p) => p.asset == status.asset);
      final assetCdps =
          data.cdps.where((c) => c.asset == status.asset).toList();
      final totalMinted =
          assetCdps.fold(0.0, (s, c) => s + c.mintedAmount);
      final spCoverage = (pool != null && totalMinted > 0)
          ? pool.totalAmount / totalMinted
          : 0.0;

      return _AssetHealthCard(
        status: status,
        spCoverage: spCoverage,
        cdpCount: assetCdps.length,
        index: i,
        indigoAsset: data.indigoAssets
            .firstWhereOrNull((a) => a.asset == status.asset),
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const IISectionHeader('Asset Health'),
        const SizedBox(height: 8),
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: cards.mapIndexed((i, card) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: i == 0 ? 0 : 12),
                child: card,
              ),
            )).toList(),
          )
        else
          ...cards.map((card) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: card,
          )),
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
    this.indigoAsset,
  });

  final AssetStatus status;
  final double spCoverage;
  final int cdpCount;
  final int index;
  final IndigoAsset? indigoAsset;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final styles = AppTextStyles.of(context);

    Color crColor(double cr) {
      final asset = indigoAsset;
      if (asset != null) {
        if (cr >= asset.maintenanceRatio + 20) return colors.success;
        if (cr >= asset.maintenanceRatio) return colors.warning;
        if (cr >= asset.liquidationRatio) return colors.warning;
        return colors.error;
      }
      // Fallback if IndigoAsset not available
      if (cr >= 200) return colors.success;
      if (cr >= 150) return colors.warning;
      return colors.error;
    }

    final crFraction = (status.totalCollateralRatio / 300).clamp(0.0, 1.0);
    final spFraction = spCoverage.clamp(0.0, 1.0);
    final abbr = getAbbreviation(status.totalSupply);

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
              value: '${status.totalCollateralRatio.toStringAsFixed(1)}%',
              fraction: crFraction,
              color: crColor(status.totalCollateralRatio),
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
              label: 'Supply',
              value:
                  '${numberAbbreviatedFormatter(status.totalSupply, abbr)} ${status.asset}',
              valueStyle: styles.monoSm,
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
