import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:indigo_insights/models/asset_price.dart';
import 'package:indigo_insights/models/collateral_pair.dart';
import 'package:indigo_insights/models/indigo_asset.dart';
import 'package:indigo_insights/repositories/asset_price_repository.dart';
import 'package:indigo_insights/repositories/indigo_asset_repository.dart';
import 'package:indigo_insights/service_locator.dart';
import 'package:indigo_insights/theme/app_color_scheme.dart';
import 'package:indigo_insights/theme/app_text_styles.dart';
import 'package:indigo_insights/utils/async_builder.dart';
import 'package:indigo_insights/utils/formatters.dart';
import 'package:indigo_insights/widgets/ii_card.dart';
import 'package:indigo_insights/widgets/ii_disclaimer.dart';
import 'package:indigo_insights/widgets/ii_tab_bar.dart';
import 'package:indigo_insights/widgets/ii_top_bar.dart';
import 'package:indigo_insights/models/asset_status.dart';
import 'package:indigo_insights/repositories/asset_status_repository.dart';
import 'package:indigo_insights/utils/collateral_prices.dart';

typedef _SimulatorData = ({
  List<IndigoAsset> assets,
  List<AssetPrice> prices,
  List<AssetStatus> statuses,
});

class PositionSimulatorInsights extends StatelessWidget {
  const PositionSimulatorInsights({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const IITopBar(title: 'Position Simulator'),
        Expanded(
          child: SelectionArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: AsyncBuilder<_SimulatorData>(
                  fetcher: () async {
                    final results = await Future.wait([
                      sl<IndigoAssetRepository>().getAssets(),
                      sl<AssetPriceRepository>().getPrices(),
                      sl<AssetStatusRepository>().getStatuses(),
                    ]);
                    return (
                      assets: results[0] as List<IndigoAsset>,
                      prices: results[1] as List<AssetPrice>,
                      statuses: results[2] as List<AssetStatus>,
                    );
                  },
                  builder: (data) => _SimulatorLayout(data: data),
                  errorBuilder: (error, retry) =>
                      Center(child: Text(error.toString())),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Stateful layout ──────────────────────────────────────────────────────────

class _SimulatorLayout extends StatefulWidget {
  final _SimulatorData data;
  const _SimulatorLayout({required this.data});

  @override
  State<_SimulatorLayout> createState() => _SimulatorLayoutState();
}

class _SimulatorLayoutState extends State<_SimulatorLayout>
    with SingleTickerProviderStateMixin {
  late TabController _assetTabController;
  int _selectedAssetIndex = 0;
  String _selectedCollateral = ''; // '' = ADA
  final _collateralCtrl = TextEditingController(text: '10000');
  final _mintedCtrl = TextEditingController(text: '1000');

  @override
  void initState() {
    super.initState();
    _assetTabController = TabController(
      length: widget.data.assets.length,
      vsync: this,
    );
    _assetTabController.addListener(() {
      if (!_assetTabController.indexIsChanging) {
        final newAsset = widget.data.assets[_assetTabController.index];
        setState(() {
          _selectedAssetIndex = _assetTabController.index;
          // Default to ADA pair when switching assets.
          _selectedCollateral =
              newAsset.collateralAssets.any((p) => p.collateralAsset.isEmpty)
                  ? ''
                  : newAsset.collateralAssets.firstOrNull?.collateralAsset ?? '';
        });
      }
    });
  }

  @override
  void dispose() {
    _assetTabController.dispose();
    _collateralCtrl.dispose();
    _mintedCtrl.dispose();
    super.dispose();
  }

  IndigoAsset get _asset => widget.data.assets[_selectedAssetIndex];

  CollateralPair? get _pair =>
      _asset.collateralAssets
          .firstWhereOrNull((p) => p.collateralAsset == _selectedCollateral) ??
      _asset.collateralAssets.firstOrNull;

  String get _collLabel => collateralLabel(_selectedCollateral);

  /// Collateral units per 1 iAsset for the *selected* collateral. Falling back
  /// to another collateral's pair (or to 1.0) silently produced ratios for the
  /// wrong token, so unresolved prices yield 0 and the UI shows no numbers.
  double get _price =>
      CollateralPrices.from(
        widget.data.statuses,
        widget.data.prices,
      ).priceFor(_asset.asset, _selectedCollateral) ??
      0.0;

  // interestRate from CollateralPair is a decimal fraction (e.g. 0.035 = 3.5%).
  double get _interestRate => _pair?.interestRate ?? 0.0;

  double get _collateral => double.tryParse(_collateralCtrl.text) ?? 0.0;
  double get _minted => double.tryParse(_mintedCtrl.text) ?? 0.0;

  double get _cr {
    if (_minted <= 0 || _price <= 0) return double.infinity;
    return (_collateral / _price / _minted) * 100;
  }

  double get _liqPrice {
    final pair = _pair;
    if (_minted <= 0 || pair == null) return 0;
    return _collateral / (_minted * (pair.liquidationRatioPercent / 100));
  }

  double get _maintenancePrice {
    final pair = _pair;
    if (_minted <= 0 || pair == null) return 0;
    return _collateral / (_minted * (pair.maintenanceRatioPercent / 100));
  }

  double get _rmrPrice {
    final pair = _pair;
    if (_minted <= 0 || pair == null) return 0;
    return _collateral / (_minted * (pair.redemptionRatioPercent / 100));
  }

  /// Fall in collateral value before liquidation. Prices are collateral units
  /// per 1 iAsset, so the collateral is worth 1/price and liquidation happens
  /// when the quote *rises* to [_liqPrice] — the drop is `1 - price/liqPrice`.
  double get _dropToLiq {
    if (_price <= 0 || _liqPrice <= 0) return 0;
    return (1 - _price / _liqPrice) * 100;
  }

  double _collateralToReachCr(double targetCr) {
    if (_minted <= 0) return 0;
    final needed = _minted * _price * (targetCr / 100);
    return (needed - _collateral).clamp(0, double.infinity);
  }

  double _assetToRepayForCr(double targetCr) {
    if (_price <= 0 || targetCr <= 0) return 0;
    final maxMint = (_collateral / _price) / (targetCr / 100);
    return (_minted - maxMint).clamp(0, double.infinity);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final styles = AppTextStyles.of(context);
    final pair = _pair;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;

        // Collateral selector chips — only shown when > 1 collateral type.
        Widget? collateralSelector;
        if (_asset.collateralAssets.length > 1) {
          collateralSelector = Wrap(
            spacing: 8,
            children: _asset.collateralAssets.map((p) {
              final isSelected = p.collateralAsset == _selectedCollateral;
              return ChoiceChip(
                label: Text(collateralLabel(p.collateralAsset)),
                selected: isSelected,
                onSelected: (_) =>
                    setState(() => _selectedCollateral = p.collateralAsset),
                selectedColor: colors.primary.withValues(alpha: 0.2),
                labelStyle: styles.bodySm.copyWith(
                  color: isSelected ? colors.primary : colors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              );
            }).toList(),
          );
        }

        final header = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your CDP parameters to analyse risk and safety margins.',
              style: styles.bodySm.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: 12),
            IITabBar(
              controller: _assetTabController,
              tabs: widget.data.assets.map((a) => a.asset).toList(),
            ),
            if (collateralSelector != null) ...[
              const SizedBox(height: 8),
              collateralSelector,
            ],
            const SizedBox(height: 8),
            Text(
              'Current ${_asset.asset} price: ${numberFormatter(_price, 4)} $_collLabel',
              style: styles.bodySm.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: 14),
          ],
        );

        final leftPane = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionCard(
              title: 'Position',
              child: Column(
                children: [
                  _NumField(
                    label: 'Collateral ($_collLabel)',
                    controller: _collateralCtrl,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 8),
                  _NumField(
                    label: 'Minted (${_asset.asset})',
                    controller: _mintedCtrl,
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Position Metrics',
              child: Column(
                children: [
                  _MetricRow(
                    'Current CR',
                    _cr.isInfinite ? '∞' : '${_cr.toStringAsFixed(1)}%',
                  ),
                  _MetricRow(
                    'Liquidation Price',
                    '${numberFormatter(_liqPrice, 4)} $_collLabel',
                    color: colors.error,
                  ),
                  _MetricRow(
                    'Maintenance Price',
                    '${numberFormatter(_maintenancePrice, 4)} $_collLabel',
                    color: colors.warning,
                  ),
                  _MetricRow(
                    'RMR Price',
                    '${numberFormatter(_rmrPrice, 4)} $_collLabel',
                    color: colors.warning,
                  ),
                  _MetricRow(
                    'Drop to Liquidation',
                    '${_dropToLiq.toStringAsFixed(1)}%',
                    color: _dropToLiq < 15 ? colors.error : colors.success,
                  ),
                  const Divider(height: 20),
                  Text(
                    'To reach 200% CR:',
                    style: styles.sectionLabel.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _MetricRow(
                    'Add Collateral',
                    '${numberFormatter(_collateralToReachCr(200), 0)} $_collLabel',
                  ),
                  _MetricRow(
                    'Or Repay Debt',
                    '${numberFormatter(_assetToRepayForCr(200), 2)} ${_asset.asset}',
                  ),
                ],
              ),
            ),
          ],
        );

        final rightPane = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionCard(
              title: 'Safety Gauge',
              child: _GaugeContent(
                cr: _cr.isInfinite ? 999 : _cr,
                liqRatio: pair?.liquidationRatioPercent,
                mcr: pair?.maintenanceRatioPercent,
                rmr: pair?.redemptionRatioPercent,
              ),
            ),
            const SizedBox(height: 12),
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _SectionCard(
                      title: 'Price Scenario Table',
                      child: _ScenarioTable(
                        pair: pair,
                        collateral: _collateral,
                        minted: _minted,
                        currentPrice: _price,
                        iAsset: _asset.asset,
                        collLabel: _collLabel,
                      ),
                    ),
                  ),
                  if (_interestRate > 0) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SectionCard(
                        title: 'Interest Cost Projection',
                        child: _InterestProjection(
                          iAsset: _asset.asset,
                          minted: _minted,
                          interestRate: _interestRate,
                          currentPrice: _price,
                          collLabel: _collLabel,
                        ),
                      ),
                    ),
                  ],
                ],
              )
            else ...[
              _SectionCard(
                title: 'Price Scenario Table',
                child: _ScenarioTable(
                  pair: pair,
                  collateral: _collateral,
                  minted: _minted,
                  currentPrice: _price,
                  iAsset: _asset.asset,
                  collLabel: _collLabel,
                ),
              ),
              if (_interestRate > 0) ...[
                const SizedBox(height: 12),
                _SectionCard(
                  title: 'Interest Cost Projection',
                  child: _InterestProjection(
                    iAsset: _asset.asset,
                    minted: _minted,
                    interestRate: _interestRate,
                    currentPrice: _price,
                    collLabel: _collLabel,
                  ),
                ),
              ],
            ],
          ],
        );

        if (isWide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 380, child: leftPane),
                  const SizedBox(width: 16),
                  Expanded(child: rightPane),
                ],
              ),
              const IIDisclaimer(),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header,
            leftPane,
            const SizedBox(height: 12),
            rightPane,
            const IIDisclaimer(),
          ],
        );
      },
    );
  }
}

// ─── Section Card wrapper ─────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final styles = AppTextStyles.of(context);
    return IICard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: styles.cardTitle),
          const SizedBox(height: 12),
          child,
        ],
      ),
    ).animate().fade(duration: 350.ms);
  }
}

// ─── Gauge content ────────────────────────────────────────────────────────────

class _GaugeContent extends StatelessWidget {
  final double cr;
  final double? liqRatio;
  final double? mcr;
  final double? rmr;

  const _GaugeContent({
    required this.cr,
    required this.liqRatio,
    required this.mcr,
    required this.rmr,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final styles = AppTextStyles.of(context);

    Color zoneColor() {
      if (liqRatio != null && cr < liqRatio! + 10) return colors.error;
      if (mcr != null && cr < mcr!) return colors.warning;
      if (rmr != null && cr < rmr!) return colors.warning;
      return colors.success;
    }

    String zoneLabel() {
      if (liqRatio != null && cr < liqRatio! + 10) return 'CRITICAL — Near Liquidation';
      if (mcr != null && cr < mcr!) return 'DANGER — Below MCR';
      if (rmr != null && cr < rmr!) return 'CAUTION — Below RMR';
      if (cr < 200) return 'MODERATE — Safe';
      return 'HEALTHY — Well Collateralized';
    }

    final cappedCr = cr.clamp(0, 400).toDouble();
    final color = zoneColor();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Text(
            '${cr > 999 ? '>999' : cr.toStringAsFixed(1)}%',
            style: styles.displayValue.copyWith(color: color),
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: cappedCr / 400,
            backgroundColor: colors.canvas,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 20,
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            zoneLabel(),
            style: styles.bodySm.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Divider(height: 20),
        if (liqRatio != null)
          _ThresholdRow('Liquidation (LR)', liqRatio!, colors.error)
        else
          _ThresholdRowNA('Liquidation (LR)', colors.textMuted),
        if (mcr != null)
          _ThresholdRow('Maintenance (MCR)', mcr!, colors.warning)
        else
          _ThresholdRowNA('Maintenance (MCR)', colors.textMuted),
        if (rmr != null)
          _ThresholdRow('Redemption (RMR)', rmr!, colors.warning)
        else
          _ThresholdRowNA('Redemption (RMR)', colors.textMuted),
      ],
    );
  }
}

// ─── Scenario Table ───────────────────────────────────────────────────────────

class _ScenarioTable extends StatelessWidget {
  final CollateralPair? pair;
  final double collateral;
  final double minted;
  final double currentPrice;
  final String iAsset;
  final String collLabel;

  const _ScenarioTable({
    required this.pair,
    required this.collateral,
    required this.minted,
    required this.currentPrice,
    required this.iAsset,
    required this.collLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final styles = AppTextStyles.of(context);
    const drops = [0, 10, 20, 30, 40, 50];

    final liq = pair?.liquidationRatioPercent;
    final mcr = pair?.maintenanceRatioPercent;
    final rmr = pair?.redemptionRatioPercent;

    return SizedBox(
      width: double.infinity,
      child: DataTable(
        columnSpacing: 14,
        headingRowHeight: 30,
        dataRowMinHeight: 26,
        dataRowMaxHeight: 32,
        columns: [
          DataColumn(label: Text('Drop', style: styles.monoSm)),
          DataColumn(label: Text('$collLabel Price', style: styles.monoSm)),
          DataColumn(label: Text('CR%', style: styles.monoSm)),
          DataColumn(label: Text('Status', style: styles.monoSm)),
        ],
        rows: drops.map((drop) {
          // A drop in collateral value raises the collateral-per-iAsset quote,
          // which is what lowers the collateral ratio.
          final simPrice = drop >= 100
              ? double.infinity
              : currentPrice / (1 - drop / 100);
          double cr = double.infinity;
          if (minted > 0 && simPrice.isFinite && simPrice > 0) {
            cr = (collateral / simPrice / minted) * 100;
          }
          final status = (liq != null && cr < liq)
              ? 'LIQUIDATED'
              : (mcr != null && cr < mcr)
              ? 'Below MCR'
              : (rmr != null && cr < rmr)
              ? 'Below RMR'
              : 'Safe';
          final statusColor = (liq != null && cr < liq)
              ? colors.error
              : (mcr != null && cr < mcr)
              ? colors.warning
              : (rmr != null && cr < rmr)
              ? colors.warning
              : colors.success;
          return DataRow(
            cells: [
              DataCell(Text('-$drop%', style: styles.monoSm)),
              DataCell(
                Text(
                  simPrice.isFinite ? numberFormatter(simPrice, 4) : '—',
                  style: styles.monoSm,
                ),
              ),
              DataCell(
                Text(
                  cr.isInfinite ? '∞' : '${cr.toStringAsFixed(0)}%',
                  style: styles.monoSm.copyWith(color: statusColor),
                ),
              ),
              DataCell(
                Text(status, style: styles.monoSm.copyWith(color: statusColor)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ─── Interest Projection ──────────────────────────────────────────────────────

class _InterestProjection extends StatelessWidget {
  final String iAsset;
  final double minted;
  // Decimal fraction (e.g. 0.035 = 3.5% APR).
  final double interestRate;
  final double currentPrice;
  final String collLabel;

  const _InterestProjection({
    required this.iAsset,
    required this.minted,
    required this.interestRate,
    required this.currentPrice,
    required this.collLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final styles = AppTextStyles.of(context);

    ({double iAssetAmt, double collateral}) forDays(int days) {
      final i = minted * interestRate * (days / 365);
      return (iAssetAmt: i, collateral: i * currentPrice);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rate: ${(interestRate * 100).toStringAsFixed(2)}% APR',
          style: styles.sectionLabel.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: 8),
        for (final entry in [
          (label: '30 days', data: forDays(30)),
          (label: '90 days', data: forDays(90)),
          (label: '180 days', data: forDays(180)),
          (label: '365 days', data: forDays(365)),
          (label: '730 days', data: forDays(730)),
        ])
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3.75),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  entry.label,
                  style: styles.bodySm.copyWith(color: colors.textSecondary),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${numberFormatter(entry.data.iAssetAmt, 4)} $iAsset',
                      style: styles.monoSm,
                    ),
                    Text(
                      '≈ ${numberFormatter(entry.data.collateral, 2)} $collLabel',
                      style: styles.monoSm.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ─── Shared helper widgets ────────────────────────────────────────────────────

class _NumField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _NumField({
    required this.label,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final styles = AppTextStyles.of(context);
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      decoration: InputDecoration(
        labelText: label,
        labelStyle: styles.bodySm.copyWith(color: colors.textSecondary),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
      ),
      style: styles.bodySm,
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _MetricRow(this.label, this.value, {this.color});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final styles = AppTextStyles.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: styles.bodySm.copyWith(color: colors.textSecondary)),
          Text(
            value,
            style: styles.monoSm.copyWith(
              color: color ?? colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThresholdRowNA extends StatelessWidget {
  final String label;
  final Color color;
  const _ThresholdRowNA(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    final styles = AppTextStyles.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: styles.bodySm.copyWith(color: color)),
          Text('—', style: styles.monoSm.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _ThresholdRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _ThresholdRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final styles = AppTextStyles.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: styles.bodySm.copyWith(color: colors.textSecondary)),
          Text(
            '${value.toStringAsFixed(1)}%',
            style: styles.monoSm.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
