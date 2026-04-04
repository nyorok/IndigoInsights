import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:indigo_insights/models/asset_interest_rate.dart';
import 'package:indigo_insights/models/asset_price.dart';
import 'package:indigo_insights/models/indigo_asset.dart';
import 'package:indigo_insights/repositories/asset_price_repository.dart';
import 'package:indigo_insights/repositories/cdp_repository.dart';
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

typedef _SimulatorData = ({
  List<IndigoAsset> assets,
  List<AssetPrice> prices,
  List<AssetInterestRate> rates,
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
                      sl<CdpRepository>().getAssetInterestRates(),
                    ]);
                    return (
                      assets: results[0] as List<IndigoAsset>,
                      prices: results[1] as List<AssetPrice>,
                      rates: results[2] as List<AssetInterestRate>,
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

// ─── Single stateful layout — no prop-drilling ───────────────────────────────

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
        setState(() => _selectedAssetIndex = _assetTabController.index);
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

  double get _price =>
      widget.data.prices
          .firstWhereOrNull((p) => p.asset == _asset.asset)
          ?.price ??
      1.0;

  double get _interestRate =>
      widget.data.rates
          .firstWhereOrNull((r) => r.asset == _asset.asset)
          ?.interestRate ??
      0.0;

  double get _collateral => double.tryParse(_collateralCtrl.text) ?? 0.0;
  double get _minted => double.tryParse(_mintedCtrl.text) ?? 0.0;

  double get _cr {
    if (_minted <= 0 || _price <= 0) return double.infinity;
    return (_collateral / _price / _minted) * 100;
  }

  double get _liqPrice {
    if (_minted <= 0) return 0;
    return _collateral / (_minted * (_asset.liquidationRatio / 100));
  }

  double get _maintenancePrice {
    if (_minted <= 0) return 0;
    return _collateral / (_minted * (_asset.maintenanceRatio / 100));
  }

  double get _rmrPrice {
    if (_minted <= 0) return 0;
    return _collateral / (_minted * (_asset.rmr / 100));
  }

  double get _dropToLiq {
    if (_price <= 0 || _liqPrice <= 0) return 0;
    return ((_price - _liqPrice) / _price) * 100;
  }

  double _adaToReachCr(double targetCr) {
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;

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
            const SizedBox(height: 8),
            Text(
              'Current ${_asset.asset} price: ${numberFormatter(_price, 4)} ADA',
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
                    label: 'Collateral (ADA)',
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
                    '${numberFormatter(_liqPrice, 4)} ADA',
                    color: colors.error,
                  ),
                  _MetricRow(
                    'Maintenance Price',
                    '${numberFormatter(_maintenancePrice, 4)} ADA',
                    color: colors.warning,
                  ),
                  _MetricRow(
                    'RMR Price',
                    '${numberFormatter(_rmrPrice, 4)} ADA',
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
                    '${numberFormatter(_adaToReachCr(200), 0)} ADA',
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
                liqRatio: _asset.liquidationRatio,
                mcr: _asset.maintenanceRatio,
                rmr: _asset.rmr,
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
                        asset: _asset,
                        collateral: _collateral,
                        minted: _minted,
                        currentPrice: _price,
                      ),
                    ),
                  ),
                  if (_interestRate > 0) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SectionCard(
                        title: 'Interest Cost Projection',
                        child: _InterestProjection(
                          asset: _asset,
                          minted: _minted,
                          interestRate: _interestRate,
                          currentPrice: _price,
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
                  asset: _asset,
                  collateral: _collateral,
                  minted: _minted,
                  currentPrice: _price,
                ),
              ),
              if (_interestRate > 0) ...[
                const SizedBox(height: 12),
                _SectionCard(
                  title: 'Interest Cost Projection',
                  child: _InterestProjection(
                    asset: _asset,
                    minted: _minted,
                    interestRate: _interestRate,
                    currentPrice: _price,
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
  final double liqRatio;
  final double mcr;
  final double rmr;

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
      if (cr < liqRatio + 10) return colors.error;
      if (cr < mcr) return colors.warning;
      if (cr < rmr) return colors.warning;
      if (cr < 200) return colors.success;
      return colors.success;
    }

    String zoneLabel() {
      if (cr < liqRatio + 10) return 'CRITICAL — Near Liquidation';
      if (cr < mcr) return 'DANGER — Below MCR';
      if (cr < rmr) return 'CAUTION — Below RMR';
      if (cr < 200) return 'MODERATE — Safe';
      return 'HEALTHY — Well Collateralized';
    }

    final cappedCr = cr.clamp(0, 400).toDouble();
    final fraction = cappedCr / 400;
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
            value: fraction,
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
        _ThresholdRow('Liquidation (LR)', liqRatio, colors.error),
        _ThresholdRow('Maintenance (MCR)', mcr, colors.warning),
        _ThresholdRow('Redemption (RMR)', rmr, colors.warning),
      ],
    );
  }
}

// ─── Scenario Table ───────────────────────────────────────────────────────────

class _ScenarioTable extends StatelessWidget {
  final IndigoAsset asset;
  final double collateral;
  final double minted;
  final double currentPrice;

  const _ScenarioTable({
    required this.asset,
    required this.collateral,
    required this.minted,
    required this.currentPrice,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final styles = AppTextStyles.of(context);
    final drops = [0, 10, 20, 30, 40, 50];

    return SizedBox(
      width: double.infinity,
      child: DataTable(
        columnSpacing: 14,
        headingRowHeight: 30,
        dataRowMinHeight: 26,
        dataRowMaxHeight: 32,
        columns: [
          DataColumn(label: Text('Drop', style: styles.monoSm)),
          DataColumn(label: Text('Asset Price', style: styles.monoSm)),
          DataColumn(label: Text('CR%', style: styles.monoSm)),
          DataColumn(label: Text('Status', style: styles.monoSm)),
        ],
        rows: drops.map((drop) {
          final simPrice = drop >= 100
              ? double.infinity
              : currentPrice / (1 - drop / 100);
          double cr = double.infinity;
          if (minted > 0 && simPrice.isFinite && simPrice > 0) {
            cr = (collateral / simPrice / minted) * 100;
          }
          final liq = asset.liquidationRatio;
          final status = cr < liq
              ? 'LIQUIDATED'
              : cr < asset.maintenanceRatio
              ? 'Below MCR'
              : cr < asset.rmr
              ? 'Below RMR'
              : 'Safe';
          final statusColor = cr < liq
              ? colors.error
              : cr < asset.maintenanceRatio
              ? colors.warning
              : cr < asset.rmr
              ? colors.warning
              : colors.success;
          return DataRow(
            cells: [
              DataCell(Text('-$drop%', style: styles.monoSm)),
              DataCell(
                Text(numberFormatter(simPrice, 4), style: styles.monoSm),
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
  final IndigoAsset asset;
  final double minted;
  final double interestRate;
  final double currentPrice;

  const _InterestProjection({
    required this.asset,
    required this.minted,
    required this.interestRate,
    required this.currentPrice,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final styles = AppTextStyles.of(context);

    ({double iAsset, double ada}) forDays(int days) {
      final i = minted * (interestRate / 100) * (days / 365);
      return (iAsset: i, ada: i * currentPrice);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rate: ${interestRate.toStringAsFixed(2)}% APR',
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
                      '${numberFormatter(entry.data.iAsset, 4)} ${asset.asset}',
                      style: styles.monoSm,
                    ),
                    Text(
                      '≈ ${numberFormatter(entry.data.ada, 2)} ADA',
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
          Text(
            label,
            style: styles.bodySm.copyWith(color: colors.textSecondary),
          ),
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
          Text(
            label,
            style: styles.bodySm.copyWith(color: colors.textSecondary),
          ),
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
