import 'package:indigo_insights/router.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:indigo_insights/models/asset_price.dart';
import 'package:indigo_insights/models/cdp.dart';
import 'package:indigo_insights/models/indigo_asset.dart';
import 'package:indigo_insights/repositories/asset_price_repository.dart';
import 'package:indigo_insights/repositories/cdp_repository.dart';
import 'package:indigo_insights/repositories/indigo_asset_repository.dart';
import 'package:indigo_insights/service_locator.dart';
import 'package:indigo_insights/theme/app_color_scheme.dart';
import 'package:indigo_insights/theme/app_text_styles.dart';
import 'package:indigo_insights/theme/gradients.dart';
import 'package:indigo_insights/utils/async_builder.dart';
import 'package:indigo_insights/utils/formatters.dart';
import 'package:indigo_insights/widgets/ii_card.dart';
import 'package:indigo_insights/widgets/ii_tab_bar.dart';
import 'package:indigo_insights/widgets/ii_top_bar.dart';

typedef _CdpExplorerData = ({
  List<Cdp> cdps,
  List<AssetPrice> prices,
  List<IndigoAsset> assets,
});

// ─── Tier definitions ─────────────────────────────────────────────────────────

enum _CdpTier { whale, shark, dolphin, fish, shrimp }

extension _CdpTierX on _CdpTier {
  String get label => switch (this) {
        _CdpTier.whale => 'Whale\n>1M ADA',
        _CdpTier.shark => 'Shark\n100k–1M',
        _CdpTier.dolphin => 'Dolphin\n10k–100k',
        _CdpTier.fish => 'Fish\n100–10k',
        _CdpTier.shrimp => 'Shrimp\n<100 ADA',
      };

  bool matches(Cdp cdp) => switch (this) {
        _CdpTier.whale => cdp.collateralAmount >= 1000000,
        _CdpTier.shark =>
          cdp.collateralAmount >= 100000 && cdp.collateralAmount < 1000000,
        _CdpTier.dolphin =>
          cdp.collateralAmount >= 10000 && cdp.collateralAmount < 100000,
        _CdpTier.fish =>
          cdp.collateralAmount >= 100 && cdp.collateralAmount < 10000,
        _CdpTier.shrimp => cdp.collateralAmount < 100,
      };
}

// ─── Root widget ──────────────────────────────────────────────────────────────

class CdpExplorerInsights extends StatelessWidget {
  const CdpExplorerInsights({super.key, this.initialTab});

  final String? initialTab;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const IITopBar(title: 'CDP Explorer'),
        Expanded(
          child: AsyncBuilder<_CdpExplorerData>(
            fetcher: () async {
              final results = await Future.wait([
                sl<CdpRepository>().getCdps(),
                sl<AssetPriceRepository>().getPrices(),
                sl<IndigoAssetRepository>().getAssets(),
              ]);
              return (
                cdps: results[0] as List<Cdp>,
                prices: results[1] as List<AssetPrice>,
                assets: results[2] as List<IndigoAsset>,
              );
            },
            builder: (data) => _CdpExplorerContent(data: data, initialTab: initialTab),
            errorBuilder: (error, retry) =>
                Center(child: Text(error.toString())),
          ),
        ),
      ],
    );
  }
}

// ─── Content with iAsset tab bar ─────────────────────────────────────────────

class _CdpExplorerContent extends StatefulWidget {
  final _CdpExplorerData data;
  final String? initialTab;
  const _CdpExplorerContent({required this.data, this.initialTab});

  @override
  State<_CdpExplorerContent> createState() => _CdpExplorerContentState();
}

class _CdpExplorerContentState extends State<_CdpExplorerContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<IndigoAsset> _sortedAssets;

  @override
  void initState() {
    super.initState();
    _sortedAssets = [...widget.data.assets];
    _sortedAssets.sort((a, b) {
      final aTotal = widget.data.cdps
              .where((c) => c.asset == a.asset)
              .fold(0.0, (s, c) => s + c.mintedAmount) *
          (widget.data.prices
                  .firstWhereOrNull((p) => p.asset == a.asset)
                  ?.price ??
              0.0);
      final bTotal = widget.data.cdps
              .where((c) => c.asset == b.asset)
              .fold(0.0, (s, c) => s + c.mintedAmount) *
          (widget.data.prices
                  .firstWhereOrNull((p) => p.asset == b.asset)
                  ?.price ??
              0.0);
      return bTotal.compareTo(aTotal);
    });
    int initialIndex = 0;
    if (widget.initialTab != null) {
      final idx = _sortedAssets.indexWhere((a) => a.asset == widget.initialTab);
      if (idx >= 0) initialIndex = idx;
    }
    _tabController = TabController(
      length: _sortedAssets.length,
      vsync: this,
      initialIndex: initialIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            IITabBar(
              tabs: _sortedAssets.map((a) => a.asset).toList(),
              controller: _tabController,
              onTap: (i) => context.goTab(_sortedAssets[i].asset),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _sortedAssets.map((asset) {
                  final price = widget.data.prices
                          .firstWhereOrNull((p) => p.asset == asset.asset)
                          ?.price ??
                      1.0;
                  final assetCdps = widget.data.cdps
                      .where((c) => c.asset == asset.asset)
                      .toList();
                  return _AssetCdpTab(
                    asset: asset,
                    cdps: assetCdps,
                    assetPriceAda: price,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Per-Asset Tab ─────────────────────────────────────────────────────────────

class _AssetCdpTab extends StatefulWidget {
  final IndigoAsset asset;
  final List<Cdp> cdps;
  final double assetPriceAda;

  const _AssetCdpTab({
    required this.asset,
    required this.cdps,
    required this.assetPriceAda,
  });

  @override
  State<_AssetCdpTab> createState() => _AssetCdpTabState();
}

class _AssetCdpTabState extends State<_AssetCdpTab> {
  _CdpTier _selectedTier = _CdpTier.dolphin;

  double _collateralRatio(Cdp cdp) {
    if (cdp.mintedAmount <= 0) return double.infinity;
    final collateralInAsset = cdp.collateralAmount / widget.assetPriceAda;
    return (collateralInAsset / cdp.mintedAmount) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 700;

    if (widget.cdps.isEmpty) {
      return const Center(child: Text('No CDPs for this asset.'));
    }

    final sizeTiersCard = _CdpSizeTiersCard(
      asset: widget.asset,
      cdps: widget.cdps,
      selectedTier: _selectedTier,
      onTierSelected: (t) => setState(() => _selectedTier = t),
    );

    final crChart = _CrDistributionCard(
      asset: widget.asset,
      cdps: widget.cdps,
      crOf: _collateralRatio,
    );

    final table = _CdpsTable(
      asset: widget.asset,
      cdps: widget.cdps,
      assetPriceAda: widget.assetPriceAda,
      crOf: _collateralRatio,
      tierFilter: _selectedTier,
    );

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                sizeTiersCard,
                const SizedBox(height: 16),
                Expanded(child: table),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: crChart),
        ],
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          sizeTiersCard,
          const SizedBox(height: 16),
          SizedBox(height: 400, child: table),
          const SizedBox(height: 16),
          SizedBox(height: 360, child: crChart),
        ],
      ),
    );
  }
}

// ─── CR Distribution Chart ─────────────────────────────────────────────────────

class _CrDistributionCard extends StatelessWidget {
  final IndigoAsset asset;
  final List<Cdp> cdps;
  final double Function(Cdp) crOf;

  const _CrDistributionCard({
    required this.asset,
    required this.cdps,
    required this.crOf,
  });

  static const _buckets = [
    (label: '<110%', min: 0.0, max: 110.0),
    (label: '110–125%', min: 110.0, max: 125.0),
    (label: '125–150%', min: 125.0, max: 150.0),
    (label: '150–175%', min: 150.0, max: 175.0),
    (label: '175–200%', min: 175.0, max: 200.0),
    (label: '200–250%', min: 200.0, max: 250.0),
    (label: '250–300%', min: 250.0, max: 300.0),
    (label: '300–400%', min: 300.0, max: 400.0),
    (label: '400–500%', min: 400.0, max: 500.0),
    (label: '>500%', min: 500.0, max: double.infinity),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final styles = AppTextStyles.of(context);
    final barColor = getColorByAsset(asset.asset);

    final bucketMinted = List.filled(_buckets.length, 0.0);
    for (final cdp in cdps) {
      final cr = crOf(cdp);
      if (cr == double.infinity) continue;
      for (int i = 0; i < _buckets.length; i++) {
        if (cr >= _buckets[i].min && cr < _buckets[i].max) {
          bucketMinted[i] += cdp.mintedAmount;
          break;
        }
      }
    }

    final maxMinted =
        bucketMinted.isEmpty ? 1.0 : bucketMinted.reduce((a, b) => a > b ? a : b);

    final groups = bucketMinted.mapIndexed((i, v) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: v,
            color: barColor,
            width: 28,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();

    return IICard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CR Distribution (${asset.asset})',
            style: styles.cardTitle,
          ),
          const SizedBox(height: 4),
          Text(
            'Minted ${asset.asset} by Collateral Ratio bucket',
            style: styles.bodySm.copyWith(color: colors.textMuted),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: BarChart(
              BarChartData(
                maxY: maxMinted * 1.15,
                barGroups: groups,
                backgroundColor: Colors.transparent,
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: colors.border),
                    left: BorderSide(color: colors.border),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: colors.border, strokeWidth: 0.5),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 52,
                      getTitlesWidget: (v, meta) => Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Text(
                          numberAbbreviatedFormatter(v, getAbbreviation(v)),
                          style: styles.monoSm.copyWith(color: colors.textMuted),
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (v, meta) {
                        final idx = v.toInt();
                        if (idx < 0 || idx >= _buckets.length) {
                          return const SizedBox.shrink();
                        }
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            _buckets[idx].label,
                            style: styles.monoSm.copyWith(
                              color: colors.textMuted,
                              fontSize: 9,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => colors.surface,
                    getTooltipItem: (group, gi, rod, ri) {
                      final abbr = getAbbreviation(rod.toY);
                      return BarTooltipItem(
                        '${_buckets[group.x].label}\n${numberAbbreviatedFormatter(rod.toY, abbr)} ${asset.asset}',
                        styles.bodySm.copyWith(color: barColor),
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

// ─── CDP Size Tiers (tappable chips) ──────────────────────────────────────────

class _CdpSizeTiersCard extends StatelessWidget {
  final IndigoAsset asset;
  final List<Cdp> cdps;
  final _CdpTier selectedTier;
  final ValueChanged<_CdpTier> onTierSelected;

  const _CdpSizeTiersCard({
    required this.asset,
    required this.cdps,
    required this.selectedTier,
    required this.onTierSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final styles = AppTextStyles.of(context);

    final tiers = [
      _CdpTier.whale,
      _CdpTier.shark,
      _CdpTier.dolphin,
      _CdpTier.fish,
      _CdpTier.shrimp,
    ];

    double totalCollateral(List<Cdp> list) =>
        list.fold(0.0, (s, c) => s + c.collateralAmount);
    double totalMinted(List<Cdp> list) =>
        list.fold(0.0, (s, c) => s + c.mintedAmount);

    return IICard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CDP Size Distribution', style: styles.cardTitle),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tiers.map((tier) {
              final list = cdps.where(tier.matches).toList();
              final col = totalCollateral(list);
              final mint = totalMinted(list);
              final collAbbr = getAbbreviation(col);
              final mintAbbr = getAbbreviation(mint);
              final isSelected = selectedTier == tier;

              return Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => onTierSelected(tier),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: isSelected ? accentSelectionGradient : null,
                      color: isSelected ? null : colors.surfaceRaised,
                      border: isSelected
                          ? Border.all(color: colors.primaryBorder)
                          : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tier.label,
                          style: styles.bodySm.copyWith(
                            color: isSelected
                                ? colors.primary
                                : colors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${list.length} positions',
                          style: styles.monoSm.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                        Text(
                          '${numberAbbreviatedFormatter(col, collAbbr)} ADA',
                          style: styles.bodySm.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                        Text(
                          '${numberAbbreviatedFormatter(mint, mintAbbr)} ${asset.asset}',
                          style: styles.bodySm.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─── CDPs Table (tier-filtered) ───────────────────────────────────────────────

class _CdpsTable extends StatefulWidget {
  final IndigoAsset asset;
  final List<Cdp> cdps;
  final double assetPriceAda;
  final double Function(Cdp) crOf;
  final _CdpTier tierFilter;

  const _CdpsTable({
    required this.asset,
    required this.cdps,
    required this.assetPriceAda,
    required this.crOf,
    required this.tierFilter,
  });

  @override
  State<_CdpsTable> createState() => _CdpsTableState();
}

class _CdpsTableState extends State<_CdpsTable> {
  static const _pageSize = 20;
  int _page = 0;
  String? _copiedOwner;

  void _copy(String owner) async {
    await Clipboard.setData(ClipboardData(text: owner));
    if (!mounted) return;
    setState(() => _copiedOwner = owner);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copiedOwner = null);
  }

  @override
  void didUpdateWidget(_CdpsTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tierFilter != widget.tierFilter) _page = 0;
  }

  double _liqPrice(Cdp cdp) {
    if (cdp.mintedAmount <= 0) return 0;
    return cdp.collateralAmount / (cdp.mintedAmount * (widget.asset.liquidationRatio / 100));
  }

  Color _crColor(double cr, AppColorScheme colors) {
    final liq = widget.asset.liquidationRatio;
    final mcr = widget.asset.maintenanceRatio;
    final rmr = widget.asset.rmr;
    if (cr < liq) return colors.error;
    if (cr < mcr) return const Color(0xFFE64A19);
    if (cr < rmr) return colors.warning;
    if (cr < 200) return const Color(0xFF0288D1);
    return colors.success;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final styles = AppTextStyles.of(context);

    final filtered = widget.cdps
        .where((c) => widget.crOf(c).isFinite)
        .where(widget.tierFilter.matches)
        .sortedByCompare<double>(
          (c) => widget.crOf(c),
          (a, b) => a.compareTo(b),
        );

    final totalPages = (filtered.length / _pageSize).ceil();
    final pageItems =
        filtered.skip(_page * _pageSize).take(_pageSize).toList();

    return IICard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CDPs (${widget.asset.asset})',
                style: styles.cardTitle,
              ),
              Text(
                '${filtered.length} positions',
                style: styles.bodySm.copyWith(color: colors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('No CDPs in this tier.',
                  style: styles.bodyMd.copyWith(color: colors.textMuted)),
            )
          else ...[
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SizedBox(
                  width: double.infinity,
                  child: DataTable(
                columnSpacing: 12,
                headingRowHeight: 32,
                dataRowMinHeight: 28,
                dataRowMaxHeight: 36,
                columns: [
                  _col('Owner', styles, colors),
                  _col('Collateral', styles, colors),
                  _col('Minted', styles, colors),
                  _col('CR%', styles, colors),
                  _col('Liq. Price', styles, colors),
                  _col('Drop %', styles, colors),
                ],
                rows: pageItems.map((cdp) {
                  final cr = widget.crOf(cdp);
                  final liq = _liqPrice(cdp);
                  final drop = widget.assetPriceAda > 0
                      ? (1 - liq / widget.assetPriceAda) * 100
                      : 0.0;
                  final owner = cdp.owner.length > 12
                      ? '${cdp.owner.substring(0, 6)}…${cdp.owner.substring(cdp.owner.length - 6)}'
                      : cdp.owner;
                  final monoStyle = styles.monoSm.copyWith(color: colors.textSecondary);
                  final isCopied = _copiedOwner == cdp.owner;
                  return DataRow(
                    cells: [
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(owner, style: monoStyle),
                            const SizedBox(width: 4),
                            Tooltip(
                              message: isCopied ? 'Copied!' : 'Copy address',
                              child: InkWell(
                                onTap: () => _copy(cdp.owner),
                                borderRadius: BorderRadius.circular(4),
                                child: Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: Icon(
                                    isCopied ? Icons.check : Icons.copy_outlined,
                                    size: 12,
                                    color: isCopied ? colors.success : colors.textMuted,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      DataCell(Text(
                        '${numberFormatter(cdp.collateralAmount, 0)} ADA',
                        style: monoStyle.copyWith(color: const Color(0xFF0288D1)),
                      )),
                      DataCell(Text(
                        '${numberFormatter(cdp.mintedAmount, 2)} ${widget.asset.asset}',
                        style: monoStyle.copyWith(color: colors.primary),
                      )),
                      DataCell(Text(
                        '${cr.toStringAsFixed(1)}%',
                        style: styles.monoSm.copyWith(
                          color: _crColor(cr, colors),
                          fontWeight: FontWeight.w600,
                        ),
                      )),
                      DataCell(Text(numberFormatter(liq, 4), style: monoStyle)),
                      DataCell(Text(
                        '${drop.toStringAsFixed(1)}%',
                        style: styles.monoSm.copyWith(
                          color: drop > 15 ? colors.error : colors.textSecondary,
                        ),
                      )),
                    ],
                  );
                }                ).toList(),
              ),
            ),
            ),
            ),
            if (totalPages > 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed:
                        _page > 0 ? () => setState(() => _page--) : null,
                  ),
                  Text(
                    '${_page + 1} / $totalPages',
                    style: styles.bodySm.copyWith(color: colors.textSecondary),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _page < totalPages - 1
                        ? () => setState(() => _page++)
                        : null,
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }

  DataColumn _col(String label, AppTextStyles styles, AppColorScheme colors) =>
      DataColumn(
        label: Text(
          label.toUpperCase(),
          style: styles.sectionLabel.copyWith(color: colors.textMuted),
        ),
      );
}
