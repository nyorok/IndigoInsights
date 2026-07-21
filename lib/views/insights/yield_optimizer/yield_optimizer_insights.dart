import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:indigo_insights/theme/app_color_scheme.dart';
import 'package:indigo_insights/theme/app_text_styles.dart';
import 'package:indigo_insights/widgets/ii_card.dart';
import 'package:indigo_insights/widgets/ii_disclaimer.dart';
import 'package:indigo_insights/widgets/ii_top_bar.dart';
import 'package:indigo_insights/widgets/yield_sources.dart';

class YieldOptimizerInsights extends StatefulWidget {
  const YieldOptimizerInsights({super.key});

  @override
  State<YieldOptimizerInsights> createState() => _YieldOptimizerInsightsState();
}

class _YieldOptimizerInsightsState extends State<YieldOptimizerInsights> {
  final List<YieldRow> _rows = [];
  int _pending = 0;
  int _sortColumnIndex = 3;
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    // Each source loads independently: the table fills in as requests finish
    // and a failing third-party API only loses its own rows.
    for (final task in yieldSourceTasks()) {
      _pending++;
      task().then((rows) {
        if (!mounted) return;
        setState(() {
          _pending--;
          _rows.addAll(rows);
          _applySort();
        });
      }).catchError((Object _) {
        if (!mounted) return;
        setState(() => _pending--);
      });
    }
  }

  void _applySort() {
    _rows.sort((a, b) {
      final mult = _sortAscending ? 1 : -1;
      return switch (_sortColumnIndex) {
        0 => a.token.compareTo(b.token) * mult,
        1 => a.type.compareTo(b.type) * mult,
        3 => a.apr.compareTo(b.apr) * mult,
        _ => 0,
      };
    });
  }

  void _sort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _applySort();
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
        Text('Yield Comparison', style: styles.cardTitle),
        const SizedBox(height: 4),
        Text(
          'All Indigo-related yields side-by-side.',
          style: styles.bodySm.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: 16),
      ],
    );

    final table = _YieldComparisonTable(
      rows: _rows,
      loading: _pending > 0,
      sortColumnIndex: _sortColumnIndex,
      sortAscending: _sortAscending,
      onSort: _sort,
    );

    final topStrategies =
        TopYieldsCardView(rows: _rows, loading: _pending > 0);

    final content = isWide
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 360, child: topStrategies),
                  const SizedBox(width: 16),
                  Expanded(child: table),
                ],
              ),
              const IIDisclaimer(),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              table,
              const SizedBox(height: 16),
              topStrategies,
              const IIDisclaimer(),
            ],
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const IITopBar(title: 'Yield Optimizer'),
        Expanded(
          child: SingleChildScrollView(
            child: SelectionArea(
              child: Padding(padding: const EdgeInsets.all(24), child: content),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Yield Comparison Table ───────────────────────────────────────────────────

class _YieldComparisonTable extends StatelessWidget {
  final List<YieldRow> rows;
  final bool loading;
  final int sortColumnIndex;
  final bool sortAscending;
  final void Function(int, bool) onSort;

  const _YieldComparisonTable({
    required this.rows,
    required this.loading,
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('All Yields', style: styles.cardTitle),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                // Fill the card on wide screens; scroll when narrow.
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                  sortColumnIndex: sortColumnIndex,
                  sortAscending: sortAscending,
                  columnSpacing: 20,
                  headingRowHeight: 36,
                  dataRowMinHeight: 32,
                  dataRowMaxHeight: 40,
                  columns: [
                    DataColumn(
                      label: const Text('Token'),
                      onSort: (i, a) => onSort(i, a),
                    ),
                    DataColumn(
                      label: const Text('Type'),
                      onSort: (i, a) => onSort(i, a),
                    ),
                    const DataColumn(label: Text('Risk')),
                    DataColumn(
                      label: const Text('APR'),
                      numeric: true,
                      onSort: (i, a) => onSort(i, a),
                    ),
                    const DataColumn(label: Text('Source')),
                  ],
                  rows: rows.mapIndexed((i, row) {
                    return DataRow(
                      cells: [
                        DataCell(Text(row.token)),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                row.type,
                                style:
                                    TextStyle(color: colors.textSecondary),
                              ),
                              if (row.description != null) ...[
                                const SizedBox(width: 4),
                                Tooltip(
                                  message: row.description!,
                                  waitDuration:
                                      const Duration(milliseconds: 300),
                                  child: Icon(
                                    Icons.info_outline,
                                    size: 14,
                                    color: colors.textMuted,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: row.riskColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              row.riskLabel,
                              style: TextStyle(
                                color: row.riskColor,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            '${row.apr.toStringAsFixed(2)}%',
                            style: TextStyle(
                              color: row.apr > 0
                                  ? colors.success
                                  : colors.textMuted,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataCell(
                          row.dapp == null
                              ? Text(
                                  '—',
                                  style:
                                      TextStyle(color: colors.textMuted),
                                )
                              : DappShortcut(
                                  dapp: row.dapp!,
                                  colors: colors,
                                ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          if (loading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Loading more yields…',
                    style: styles.bodySm.copyWith(color: colors.textMuted),
                  ),
                ],
              ),
            ).animate(onPlay: (c) => c.repeat()).fade(
                  begin: 0.5,
                  end: 1,
                  duration: 700.ms,
                ),
        ],
      ),
    ).animate().fade(duration: 400.ms);
  }
}
