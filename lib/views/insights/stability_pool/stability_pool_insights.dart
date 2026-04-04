import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:indigo_insights/models/asset_price.dart';
import 'package:indigo_insights/models/cdp.dart';
import 'package:indigo_insights/models/indigo_asset.dart';
import 'package:indigo_insights/models/liquidation.dart';
import 'package:indigo_insights/models/stability_pool.dart';
import 'package:indigo_insights/repositories/asset_price_repository.dart';
import 'package:indigo_insights/repositories/cdp_repository.dart';
import 'package:indigo_insights/repositories/liquidation_repository.dart';
import 'package:indigo_insights/repositories/stability_pool_repository.dart';
import 'package:indigo_insights/service_locator.dart';
import 'package:indigo_insights/theme/app_color_scheme.dart';
import 'package:indigo_insights/theme/app_text_styles.dart';
import 'package:indigo_insights/utils/async_builder.dart';
import 'package:indigo_insights/utils/formatters.dart';
import 'package:indigo_insights/views/insights/stability_pool/stability_pool_analytics_card.dart';
import 'package:indigo_insights/views/insights/stability_pool/stability_pool_solvency_chart.dart';
import 'package:indigo_insights/widgets/ii_asset_tabs.dart';
import 'package:indigo_insights/widgets/ii_card.dart';
import 'package:indigo_insights/widgets/ii_kpi_strip.dart';
import 'package:indigo_insights/widgets/ii_top_bar.dart';

typedef _SpTabData = ({
  List<Cdp> cdps,
  AssetPrice price,
  StabilityPool? pool,
  List<Liquidation> liquidations,
});

class StabilityPoolInsights extends StatelessWidget {
  const StabilityPoolInsights({super.key, this.initialTab});

  final String? initialTab;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const IITopBar(title: 'Stability Pool'),
        Expanded(
          child: SelectionArea(
            child: IIAssetTabs(
              initialTabName: initialTab,
              tabContentBuilder: (asset) => _SpTabContent(asset: asset),
            ),
          ),
        ),
      ],
    );
  }
}

class _SpTabContent extends StatelessWidget {
  const _SpTabContent({required this.asset});
  final IndigoAsset asset;

  @override
  Widget build(BuildContext context) {
    return AsyncBuilder<_SpTabData>(
      fetcher: () async {
        final results = await Future.wait([
          sl<CdpRepository>().getCdps(),
          sl<AssetPriceRepository>().getPrices(),
          sl<StabilityPoolRepository>().getPools(),
          sl<LiquidationRepository>().getLiquidations(),
        ]);
        final cdps = (results[0] as List<Cdp>)
            .where((c) => c.asset == asset.asset)
            .toList();
        final prices = results[1] as List<AssetPrice>;
        final price = prices.firstWhereOrNull((p) => p.asset == asset.asset) ??
            AssetPrice(asset: asset.asset, price: 1.0);
        final pools = results[2] as List<StabilityPool>;
        final pool = pools.firstWhereOrNull((p) => p.asset == asset.asset);
        final liquidations = (results[3] as List<Liquidation>)
            .where((l) => l.asset == asset.asset)
            .toList();
        return (
          cdps: cdps,
          price: price,
          pool: pool,
          liquidations: liquidations,
        );
      },
      builder: (data) => _SpTabView(asset: asset, data: data),
      errorBuilder: (error, retry) => Center(child: Text(error.toString())),
    );
  }
}

class _SpTabView extends StatefulWidget {
  const _SpTabView({required this.asset, required this.data});
  final IndigoAsset asset;
  final _SpTabData data;

  @override
  State<_SpTabView> createState() => _SpTabViewState();
}

class _SpTabViewState extends State<_SpTabView> {
  double _dropPercent = 0.0;

  IndigoAsset get asset => widget.asset;
  _SpTabData get data => widget.data;

  double get simulatedPrice =>
      _dropPercent >= 100 ? double.infinity : data.price.price / (1 - _dropPercent / 100);

  List<Cdp> get liquidatableCdps => data.cdps.where((c) {
        if (c.mintedAmount <= 0) return false;
        if (simulatedPrice.isInfinite) return false;
        final collateralInAsset = c.collateralAmount / simulatedPrice;
        final cr = collateralInAsset / c.mintedAmount;
        return cr < asset.liquidationRatio / 100;
      }).toList();

  @override
  Widget build(BuildContext context) {
    final liqs = liquidatableCdps;
    final totalMintedAtRisk = liqs.fold(0.0, (s, c) => s + c.mintedAmount);
    final totalCollateralAtRisk =
        liqs.fold(0.0, (s, c) => s + c.collateralAmount * 0.98);
    final spBalance = data.pool?.totalAmount ?? 0.0;
    final spCanAbsorb = spBalance >= totalMintedAtRisk;
    final remainingSp = spBalance - totalMintedAtRisk;
    final remainingCollateral =
        (totalCollateralAtRisk - (spCanAbsorb ? totalCollateralAtRisk : spBalance / totalMintedAtRisk * totalCollateralAtRisk))
            .clamp(0.0, double.infinity);

    final mintAbbr = getAbbreviation(totalMintedAtRisk);
    final collAbbr = getAbbreviation(totalCollateralAtRisk);
    final premiumPct = (asset.liquidationRatio - 102).toStringAsFixed(0);

    final isDesktop = MediaQuery.of(context).size.width >= 700;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Existing analytics row ────────────────────────────────────────
          if (isDesktop)
            SizedBox(
              height: 380,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 320,
                    child: IICard(
                      child: SingleChildScrollView(
                        child: StabilityPoolAnalyticsCard(indigoAsset: asset),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: IICard(
                      padding: EdgeInsets.zero,
                      child: StabilityPoolSolvencyChart(indigoAsset: asset),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            IICard(
              child: StabilityPoolAnalyticsCard(indigoAsset: asset),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: IICard(
                padding: EdgeInsets.zero,
                child: StabilityPoolSolvencyChart(indigoAsset: asset),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // ── Liquidation Scenario Simulator ────────────────────────────────
          _ScenarioSimulatorSection(
            asset: asset,
            dropPercent: _dropPercent,
            onDropChanged: (v) => setState(() => _dropPercent = v),
            liqs: liqs,
            totalMintedAtRisk: totalMintedAtRisk,
            totalCollateralAtRisk: totalCollateralAtRisk,
            remainingSp: remainingSp,
            spCanAbsorb: spCanAbsorb,
            mintAbbr: mintAbbr,
            collAbbr: collAbbr,
            premiumPct: premiumPct,
            remainingCollateral: remainingCollateral,
            simulatedPrice: simulatedPrice,
          ),

          // ── Historical liquidation price stats ───────────────────────────
          if (data.liquidations.isNotEmpty) ...[
            const SizedBox(height: 16),
            _HistoricalLiqStatsStrip(liquidations: data.liquidations),
          ],

          // ── Top Endangered CDPs ───────────────────────────────────────────
          if (liqs.isNotEmpty) ...[
            const SizedBox(height: 16),
            _TopEndangeredList(
              cdps: (liqs..sort((a, b) => b.mintedAmount.compareTo(a.mintedAmount))).take(5).toList(),
              asset: asset,
              simulatedPrice: simulatedPrice,
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Scenario Simulator Section ───────────────────────────────────────────────

class _ScenarioSimulatorSection extends StatelessWidget {
  final IndigoAsset asset;
  final double dropPercent;
  final ValueChanged<double> onDropChanged;
  final List<Cdp> liqs;
  final double totalMintedAtRisk;
  final double totalCollateralAtRisk;
  final double remainingSp;
  final bool spCanAbsorb;
  final NumberAbbreviation? mintAbbr;
  final NumberAbbreviation? collAbbr;
  final String premiumPct;
  final double remainingCollateral;
  final double simulatedPrice;

  const _ScenarioSimulatorSection({
    required this.asset,
    required this.dropPercent,
    required this.onDropChanged,
    required this.liqs,
    required this.totalMintedAtRisk,
    required this.totalCollateralAtRisk,
    required this.remainingSp,
    required this.spCanAbsorb,
    required this.mintAbbr,
    required this.collAbbr,
    required this.premiumPct,
    required this.remainingCollateral,
    required this.simulatedPrice,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final styles = AppTextStyles.of(context);

    return IICard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Liquidation Scenario Simulator', style: styles.cardTitle),
          const SizedBox(height: 12),
          // Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ADA Price Drop',
                style: styles.bodySm.copyWith(color: colors.textSecondary),
              ),
              Text(
                '-${dropPercent.toStringAsFixed(0)}%  '
                '(${numberFormatter(simulatedPrice.isInfinite ? 0 : simulatedPrice, 4)} ADA)',
                style: styles.bodySm.copyWith(
                  color: dropPercent > 30 ? colors.error : colors.warning,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Slider(
            value: dropPercent,
            min: 0,
            max: 80,
            divisions: 80,
            activeColor: dropPercent > 30 ? colors.error : colors.warning,
            onChanged: onDropChanged,
          ),
          const SizedBox(height: 12),
          // Cascade panels
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _CascadePanel(
                label: 'Liquidatable CDPs',
                value: '${liqs.length}',
                sub: '${numberAbbreviatedFormatter(totalMintedAtRisk, mintAbbr)} ${asset.asset} at risk',
                color: liqs.isEmpty ? colors.success : colors.error,
                icon: Icons.warning_amber_outlined,
              ),
              _CascadePanel(
                label: 'Collateral Absorbed',
                value: '${numberAbbreviatedFormatter(totalCollateralAtRisk, collAbbr)} ADA',
                sub: 'by Stability Pool',
                color: colors.warning,
                icon: Icons.account_balance,
              ),
              _CascadePanel(
                label: 'Remaining SP After',
                value: remainingSp >= 0
                    ? '${numberAbbreviatedFormatter(remainingSp, getAbbreviation(remainingSp))} ${asset.asset}'
                    : 'SP EMPTY',
                sub: remainingSp >= 0
                    ? 'buffer remaining'
                    : 'Add funds to earn $premiumPct% ADA premium per liquidation',
                color: remainingSp >= 0 ? colors.success : colors.warning,
                icon: remainingSp >= 0
                    ? Icons.check_circle_outline
                    : Icons.savings_outlined,
              ),
              _CascadePanel(
                label: 'Remaining Collateral to Absorb',
                value: remainingCollateral > 0
                    ? '${numberAbbreviatedFormatter(remainingCollateral, getAbbreviation(remainingCollateral))} ADA'
                    : 'Fully Covered',
                sub: remainingCollateral > 0
                    ? 'not yet absorbed by SP'
                    : 'SP covers all collateral',
                color: remainingCollateral > 0 ? colors.error : colors.success,
                icon: Icons.layers_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CascadePanel extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color color;
  final IconData icon;

  const _CascadePanel({
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final styles = AppTextStyles.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 180, maxWidth: 240),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    label,
                    style: styles.sectionLabel
                        .copyWith(color: colors.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: styles.bodySm.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              sub,
              style: styles.sectionLabel.copyWith(color: colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Historical Liquidation Price Stats Strip ─────────────────────────────────

class _HistoricalLiqStatsStrip extends StatelessWidget {
  final List<Liquidation> liquidations;
  const _HistoricalLiqStatsStrip({required this.liquidations});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final prices = liquidations.map((l) => l.oraclePrice).toList()..sort();
    final minPrice = prices.first;
    final maxPrice = prices.last;
    final avgPrice = prices.reduce((a, b) => a + b) / prices.length;
    final abbr = getAbbreviation(maxPrice);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Historical Liquidation Prices',
            style: AppTextStyles.of(context).cardTitle,
          ),
        ),
        IIKpiStrip(cells: [
          IIKpiCell(
            label: 'Events',
            value: '${liquidations.length}',
          ),
          IIKpiCell(
            label: 'Min Price',
            value: numberAbbreviatedFormatter(minPrice, abbr),
            unit: 'ADA',
            valueColor: colors.error,
          ),
          IIKpiCell(
            label: 'Avg Price',
            value: numberAbbreviatedFormatter(avgPrice, abbr),
            unit: 'ADA',
            valueColor: colors.warning,
          ),
          IIKpiCell(
            label: 'Max Price',
            value: numberAbbreviatedFormatter(maxPrice, abbr),
            unit: 'ADA',
            valueColor: colors.success,
          ),
        ]),
      ],
    );
  }
}

// ─── Top Endangered CDPs ──────────────────────────────────────────────────────

class _TopEndangeredList extends StatelessWidget {
  final List<Cdp> cdps;
  final IndigoAsset asset;
  final double simulatedPrice;

  const _TopEndangeredList({
    required this.cdps,
    required this.asset,
    required this.simulatedPrice,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final styles = AppTextStyles.of(context);

    return IICard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top Endangered CDPs', style: styles.cardTitle),
          const SizedBox(height: 8),
          ...cdps.mapIndexed((i, cdp) {
            final collateralInAsset = simulatedPrice > 0 && simulatedPrice.isFinite
                ? cdp.collateralAmount / simulatedPrice
                : 0.0;
            final cr = cdp.mintedAmount > 0
                ? (collateralInAsset / cdp.mintedAmount) * 100
                : 0.0;
            final owner = cdp.owner.length > 12
                ? '${cdp.owner.substring(0, 8)}…'
                : cdp.owner;
            return ListTile(
              dense: true,
              leading: CircleAvatar(
                radius: 12,
                backgroundColor: colors.error.withValues(alpha: 0.2),
                child: Text(
                  '${i + 1}',
                  style: styles.monoSm.copyWith(color: colors.error),
                ),
              ),
              title: Text(owner, style: styles.bodySm),
              subtitle: Text(
                '${numberFormatter(cdp.collateralAmount, 0)} ADA / '
                '${numberFormatter(cdp.mintedAmount, 2)} ${asset.asset}',
                style: styles.sectionLabel
                    .copyWith(color: colors.textSecondary),
              ),
              trailing: Text(
                'CR: ${cr.toStringAsFixed(1)}%',
                style: styles.monoSm.copyWith(color: colors.error),
              ),
            );
          }),
        ],
      ),
    ).animate().fade(duration: 400.ms);
  }
}
