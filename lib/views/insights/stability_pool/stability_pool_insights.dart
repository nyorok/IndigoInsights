import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  List<AssetPrice> prices, // all (asset, collateral) price rows for this iAsset
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
        final prices = (results[1] as List<AssetPrice>)
            .where((p) => p.asset == asset.asset)
            .toList();
        final pools = results[2] as List<StabilityPool>;
        final pool = pools.firstWhereOrNull((p) => p.asset == asset.asset);
        final liquidations = (results[3] as List<Liquidation>)
            .where((l) => l.asset == asset.asset)
            .toList();
        return (cdps: cdps, prices: prices, pool: pool, liquidations: liquidations);
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

  /// Simulated price per collateral: same % drop applied to every collateral type.
  Map<String, double> get _simPrices {
    if (_dropPercent >= 100) return {};
    final factor = 1 - _dropPercent / 100;
    return {for (final p in data.prices) p.collateralAsset: p.price / factor};
  }

  List<Cdp> _liquidatable(Map<String, double> simPrices) =>
      data.cdps.where((c) {
        if (c.mintedAmount <= 0) return false;
        final sp = simPrices[c.collateralAsset];
        if (sp == null || sp.isInfinite || sp <= 0) return false;
        final cr = (c.collateralAmount / sp) / c.mintedAmount;
        return cr < asset.getLiquidationRatio(c.collateralAsset) / 100;
      }).toList();

  /// Collateral at risk grouped by collateral type (98% absorbed by SP per protocol).
  Map<String, double> _collateralByType(List<Cdp> liqs) {
    final map = <String, double>{};
    for (final c in liqs) {
      map[c.collateralAsset] =
          (map[c.collateralAsset] ?? 0) + c.collateralAmount * 0.98;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final simPrices = _simPrices;
    final liqs = _liquidatable(simPrices);
    final totalMintedAtRisk = liqs.fold(0.0, (s, c) => s + c.mintedAmount);
    final collateralByType = _collateralByType(liqs);
    final spBalance = data.pool?.totalAmount ?? 0.0;
    // Fraction of liquidatable debt the SP can absorb (0.0–1.0).
    final absorptionFraction = totalMintedAtRisk > 0
        ? (spBalance / totalMintedAtRisk).clamp(0.0, 1.0)
        : 0.0;
    final spCanAbsorb = absorptionFraction >= 1.0;
    final remainingSp = spBalance - totalMintedAtRisk;
    // Split collateral absorbed/remaining proportionally across all collateral types.
    final collateralAbsorbed = {
      for (final e in collateralByType.entries)
        e.key: e.value * absorptionFraction,
    };
    final collateralRemaining = {
      for (final e in collateralByType.entries)
        e.key: e.value * (1 - absorptionFraction),
    };

    final mintAbbr = getAbbreviation(totalMintedAtRisk);
    final premiumPct = (9.1).toStringAsFixed(1);
    final isDesktop = MediaQuery.of(context).size.width >= 700;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (data.liquidations.isNotEmpty) ...[
            _HistoricalLiqStatsStrip(liquidations: data.liquidations),
            const SizedBox(height: 16),
          ],

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
            IICard(child: StabilityPoolAnalyticsCard(indigoAsset: asset)),
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

          _ScenarioSimulatorSection(
            asset: asset,
            dropPercent: _dropPercent,
            onDropChanged: (v) => setState(() => _dropPercent = v),
            simPrices: simPrices,
            liqs: liqs,
            totalMintedAtRisk: totalMintedAtRisk,
            collateralAbsorbed: collateralAbsorbed,
            collateralRemaining: collateralRemaining,
            remainingSp: remainingSp,
            spCanAbsorb: spCanAbsorb,
            mintAbbr: mintAbbr,
            premiumPct: premiumPct,
            isDesktop: isDesktop,
          ),

          if (liqs.isNotEmpty) ...[
            const SizedBox(height: 16),
            _TopEndangeredList(
              cdps: (liqs..sort(
                    (a, b) => b.mintedAmount.compareTo(a.mintedAmount),
                  ))
                  .take(5)
                  .toList(),
              asset: asset,
              simPrices: simPrices,
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

/// Renders a multi-collateral amount map as "2.40K ADA\n1.80K NIGHT".
/// Returns "0.00" when empty.
String _collateralMapLabel(Map<String, double> amounts) {
  final parts = amounts.entries
      .where((e) => e.value > 0.0005)
      .map((e) {
        final abbr = getAbbreviation(e.value);
        return '${numberAbbreviatedFormatter(e.value, abbr)} ${collateralLabel(e.key)}';
      })
      .toList();
  return parts.isEmpty ? '0.00' : parts.join('\n');
}

// ─── Scenario Simulator Section ───────────────────────────────────────────────

class _ScenarioSimulatorSection extends StatelessWidget {
  final IndigoAsset asset;
  final double dropPercent;
  final ValueChanged<double> onDropChanged;
  final Map<String, double> simPrices;
  final List<Cdp> liqs;
  final double totalMintedAtRisk;
  final Map<String, double> collateralAbsorbed;
  final Map<String, double> collateralRemaining;
  final double remainingSp;
  final bool spCanAbsorb;
  final NumberAbbreviation? mintAbbr;
  final String premiumPct;
  final bool isDesktop;

  const _ScenarioSimulatorSection({
    required this.asset,
    required this.dropPercent,
    required this.onDropChanged,
    required this.simPrices,
    required this.liqs,
    required this.totalMintedAtRisk,
    required this.collateralAbsorbed,
    required this.collateralRemaining,
    required this.remainingSp,
    required this.spCanAbsorb,
    required this.mintAbbr,
    required this.premiumPct,
    required this.isDesktop,
  });

  /// "33.1760 ADA · 26.4009 NIGHT" style label for the slider.
  String get _priceLabel {
    final parts = simPrices.entries
        .map((e) => '${numberFormatter(e.value, 4)} ${collateralLabel(e.key)}')
        .toList();
    return parts.isEmpty ? '' : '(${parts.join(' · ')})';
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final styles = AppTextStyles.of(context);
    final hasRemaining = collateralRemaining.values.any((v) => v > 0.0005);

    final panels = [
      _CascadePanel(
        label: 'Liquidatable CDPs',
        value: '${liqs.length}',
        sub: '${numberAbbreviatedFormatter(totalMintedAtRisk, mintAbbr)} ${asset.asset} at risk',
        color: liqs.isEmpty ? colors.success : colors.error,
        icon: Icons.warning_amber_outlined,
      ),
      _CascadePanel(
        label: 'Collateral Absorbed',
        value: _collateralMapLabel(collateralAbsorbed),
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
            : 'Add funds to earn $premiumPct% premium per liquidation',
        color: remainingSp >= 0 ? colors.success : colors.warning,
        icon: remainingSp >= 0
            ? Icons.check_circle_outline
            : Icons.savings_outlined,
      ),
      _CascadePanel(
        label: 'Remaining Collateral to Absorb',
        value:
            hasRemaining ? _collateralMapLabel(collateralRemaining) : 'Fully Covered',
        sub: hasRemaining ? 'not yet absorbed by SP' : 'SP covers all collateral',
        color: hasRemaining ? colors.error : colors.success,
        icon: Icons.layers_outlined,
      ),
    ];

    return IICard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Liquidation Scenario Simulator', style: styles.cardTitle),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Collateral Price Drop',
                style: styles.bodySm.copyWith(color: colors.textSecondary),
              ),
              Text(
                '-${dropPercent.toStringAsFixed(0)}%  $_priceLabel',
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
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: panels
                  .expand((p) => [Expanded(child: p), const SizedBox(width: 10)])
                  .toList()
                ..removeLast(),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: panels
                  .expand((p) => [p, const SizedBox(height: 10)])
                  .toList()
                ..removeLast(),
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

    return Container(
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
                  style: styles.sectionLabel.copyWith(color: colors.textSecondary),
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
    final prices =
        liquidations.map((l) => l.oraclePrice).whereType<double>().toList()
          ..sort();
    if (prices.isEmpty) return const SizedBox.shrink();
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
        IIKpiStrip(
          cells: [
            IIKpiCell(label: 'Events', value: '${liquidations.length}'),
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
          ],
        ),
      ],
    );
  }
}

// ─── Top Endangered CDPs ──────────────────────────────────────────────────────

class _TopEndangeredList extends StatefulWidget {
  final List<Cdp> cdps;
  final IndigoAsset asset;
  final Map<String, double> simPrices;

  const _TopEndangeredList({
    required this.cdps,
    required this.asset,
    required this.simPrices,
  });

  @override
  State<_TopEndangeredList> createState() => _TopEndangeredListState();
}

class _TopEndangeredListState extends State<_TopEndangeredList> {
  String? _copiedOwner;

  void _copy(String owner) async {
    await Clipboard.setData(ClipboardData(text: owner));
    setState(() => _copiedOwner = owner);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copiedOwner = null);
  }

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
          ...widget.cdps.mapIndexed((i, cdp) {
            final simPrice = widget.simPrices[cdp.collateralAsset] ?? 0.0;
            final collateralInAsset =
                simPrice > 0 ? cdp.collateralAmount / simPrice : 0.0;
            final cr = cdp.mintedAmount > 0
                ? (collateralInAsset / cdp.mintedAmount) * 100
                : 0.0;
            final isCopied = _copiedOwner == cdp.owner;
            final collLabel = collateralLabel(cdp.collateralAsset);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: colors.error.withValues(alpha: 0.2),
                    child: Text(
                      '${i + 1}',
                      style: styles.monoSm.copyWith(color: colors.error),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cdp.owner,
                          style: styles.bodySm,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${numberFormatter(cdp.collateralAmount, 0)} $collLabel / '
                          '${numberFormatter(cdp.mintedAmount, 2)} ${widget.asset.asset}',
                          style: styles.sectionLabel.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'CR: ${cr.toStringAsFixed(1)}%',
                    style: styles.monoSm.copyWith(color: colors.error),
                  ),
                  const SizedBox(width: 4),
                  Tooltip(
                    message: isCopied ? 'Copied!' : 'Copy address',
                    child: InkWell(
                      onTap: () => _copy(cdp.owner),
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          isCopied ? Icons.check : Icons.copy_outlined,
                          size: 14,
                          color: isCopied ? colors.success : colors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    ).animate().fade(duration: 400.ms);
  }
}
