import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:indigo_insights/repositories/strategy_repository.dart';
import 'package:indigo_insights/service_locator.dart';
import 'package:indigo_insights/theme/app_color_scheme.dart';
import 'package:indigo_insights/theme/app_text_styles.dart';
import 'package:indigo_insights/utils/async_builder.dart';
import 'package:indigo_insights/widgets/ii_card.dart';
import 'package:indigo_insights/widgets/ii_disclaimer.dart';
import 'package:indigo_insights/widgets/ii_top_bar.dart';

typedef _OptimizerData = ({
  List<StabilityPoolStrategyData> spFarming,
  List<StablePoolStrategyData> stablePool,
  List<LeverageData> leverage,
});

class YieldOptimizerInsights extends StatelessWidget {
  const YieldOptimizerInsights({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const IITopBar(title: 'Yield Optimizer'),
        Expanded(
          child: SingleChildScrollView(
            child: SelectionArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: AsyncBuilder<_OptimizerData>(
                  fetcher: () async {
                    final results = await Future.wait([
                      sl<StrategyRepository>().getStabilityPoolFarmingData(),
                      sl<StrategyRepository>().getStablePoolFarmingData(),
                      sl<StrategyRepository>().getLeverageData(),
                    ]);
                    return (
                      spFarming: results[0] as List<StabilityPoolStrategyData>,
                      stablePool: results[1] as List<StablePoolStrategyData>,
                      leverage: results[2] as List<LeverageData>,
                    );
                  },
                  builder: (data) => _OptimizerContent(data: data),
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

// ─── Strategy Row ─────────────────────────────────────────────────────────────

class _StrategyRow {
  final String name;
  final String type;
  final double grossApr;
  final double interestCost;
  final double netApr;
  final String riskLabel;
  final Color riskColor;

  _StrategyRow({
    required this.name,
    required this.type,
    required this.grossApr,
    required this.interestCost,
    required this.netApr,
    required this.riskLabel,
    required this.riskColor,
  });
}

List<_StrategyRow> _buildRows(_OptimizerData data) {
  final rows = <_StrategyRow>[];

  for (final sp in data.spFarming) {
    rows.add(_StrategyRow(
      name: sp.title,
      type: 'SP Farming',
      grossApr: sp.poolYield,
      interestCost: sp.interestRate,
      netApr: sp.strategyYield,
      riskLabel: 'Safe',
      riskColor: const Color(0xFF00ACC1),
    ));
  }

  for (final st in data.stablePool) {
    rows.add(_StrategyRow(
      name: st.title,
      type: 'Stable Pool',
      grossApr: st.tradingFeesApr + st.farmingApr,
      interestCost: st.interestRate,
      netApr: st.strategyYield,
      riskLabel: 'Very Safe',
      riskColor: const Color(0xFF00695C),
    ));
  }

  // Leverage rows: net APR is variable (depends on how borrowed capital is deployed)
  for (final lev in data.leverage) {
    rows.add(_StrategyRow(
      name: '${lev.asset} Leverage',
      type: 'Leverage',
      grossApr: 0,
      interestCost: lev.interestRate,
      netApr: 0,
      riskLabel: 'Medium Risk',
      riskColor: const Color(0xFFFBC02D),
    ));
  }

  // Sort descending by net APR; leverage rows (0) come after positive-yield rows
  rows.sort((a, b) => b.netApr.compareTo(a.netApr));
  return rows;
}

// ─── Main Content ─────────────────────────────────────────────────────────────

class _OptimizerContent extends StatefulWidget {
  final _OptimizerData data;
  const _OptimizerContent({required this.data});

  @override
  State<_OptimizerContent> createState() => _OptimizerContentState();
}

class _OptimizerContentState extends State<_OptimizerContent> {
  int _sortColumnIndex = 4;
  bool _sortAscending = false;
  late List<_StrategyRow> _rows;

  @override
  void initState() {
    super.initState();
    _rows = _buildRows(widget.data);
  }

  void _sort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _rows.sort((a, b) {
        final mult = ascending ? 1 : -1;
        return switch (columnIndex) {
          0 => a.name.compareTo(b.name) * mult,
          1 => a.type.compareTo(b.type) * mult,
          2 => a.grossApr.compareTo(b.grossApr) * mult,
          3 => a.interestCost.compareTo(b.interestCost) * mult,
          4 => a.netApr.compareTo(b.netApr) * mult,
          _ => 0,
        };
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final styles = AppTextStyles.of(context);
    final isWide = MediaQuery.of(context).size.width >= 1080;

    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Strategy Comparison', style: styles.cardTitle),
        const SizedBox(height: 4),
        Text(
          'Compare all strategies side-by-side and calculate projected returns.',
          style: styles.bodySm.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: 16),
      ],
    );

    final table = _YieldComparisonTable(
      rows: _rows,
      sortColumnIndex: _sortColumnIndex,
      sortAscending: _sortAscending,
      onSort: _sort,
    );

    final topStrategies = _TopStrategiesCard(rows: _rows);

    if (isWide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 280, child: topStrategies),
              const SizedBox(width: 16),
              Expanded(child: table),
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
        table,
        const SizedBox(height: 16),
        topStrategies,
        const IIDisclaimer(),
      ],
    );
  }
}

// ─── Yield Comparison Table ───────────────────────────────────────────────────

class _YieldComparisonTable extends StatelessWidget {
  final List<_StrategyRow> rows;
  final int sortColumnIndex;
  final bool sortAscending;
  final void Function(int, bool) onSort;

  const _YieldComparisonTable({
    required this.rows,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.onSort,
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
          Text('All Strategies', style: styles.cardTitle),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              sortColumnIndex: sortColumnIndex,
              sortAscending: sortAscending,
              columnSpacing: 20,
              headingRowHeight: 36,
              dataRowMinHeight: 32,
              dataRowMaxHeight: 40,
              columns: [
                DataColumn(
                  label: const Text('Strategy'),
                  onSort: (i, a) => onSort(i, a),
                ),
                DataColumn(
                  label: const Text('Type'),
                  onSort: (i, a) => onSort(i, a),
                ),
                DataColumn(
                  label: const Text('Gross APR'),
                  numeric: true,
                  onSort: (i, a) => onSort(i, a),
                ),
                DataColumn(
                  label: const Text('Interest'),
                  numeric: true,
                  onSort: (i, a) => onSort(i, a),
                ),
                DataColumn(
                  label: const Text('Net APR'),
                  numeric: true,
                  onSort: (i, a) => onSort(i, a),
                ),
                const DataColumn(label: Text('Risk')),
              ],
              rows: rows.mapIndexed((i, row) {
                final isLeverage = row.type == 'Leverage';
                return DataRow(
                  cells: [
                    DataCell(Text(row.name)),
                    DataCell(Text(
                      row.type,
                      style: TextStyle(color: colors.textSecondary),
                    )),
                    DataCell(Text(
                      isLeverage ? '—' : '${row.grossApr.toStringAsFixed(2)}%',
                    )),
                    DataCell(Text(
                      '${row.interestCost.toStringAsFixed(2)}%',
                      style: TextStyle(color: colors.error),
                    )),
                    DataCell(Text(
                      isLeverage
                          ? 'Variable'
                          : '${row.netApr.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: isLeverage
                            ? colors.warning
                            : row.netApr >= 0
                                ? colors.success
                                : colors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: row.riskColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          row.riskLabel,
                          style: TextStyle(color: row.riskColor, fontSize: 11),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    ).animate().fade(duration: 400.ms);
  }
}

// ─── Top Strategies Card ──────────────────────────────────────────────────────

class _TopStrategiesCard extends StatelessWidget {
  final List<_StrategyRow> rows;
  const _TopStrategiesCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final styles = AppTextStyles.of(context);
    final top = rows.where((r) => r.netApr > 0).take(5).toList();

    return ConstrainedBox(
      constraints: const BoxConstraints(),
      child: IICard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Top Yield Strategies', style: styles.cardTitle),
            const SizedBox(height: 12),
            if (top.isEmpty)
              const Text('No positive-yield strategies available.')
            else
              ...top.mapIndexed((i, row) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 11,
                          backgroundColor:
                              colors.success.withValues(alpha: 0.2),
                          child: Text(
                            '${i + 1}',
                            style: styles.monoSm.copyWith(color: colors.success),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(row.name, style: styles.bodySm),
                              Text(row.type,
                                  style: styles.bodySm.copyWith(
                                      color: colors.textSecondary)),
                            ],
                          ),
                        ),
                        Text(
                          '${row.netApr.toStringAsFixed(2)}%',
                          style: styles.kpiValue.copyWith(color: colors.success),
                        ),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    ).animate().slideX(begin: 0.2, duration: 400.ms).fade(duration: 400.ms);
  }
}
