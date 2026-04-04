import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:indigo_insights/models/stability_pool.dart';
import 'package:indigo_insights/models/stability_pool_account.dart';
import 'package:indigo_insights/repositories/stability_pool_account_repository.dart';
import 'package:indigo_insights/repositories/stability_pool_repository.dart';
import 'package:indigo_insights/service_locator.dart';
import 'package:indigo_insights/theme/app_color_scheme.dart';
import 'package:indigo_insights/theme/app_text_styles.dart';
import 'package:indigo_insights/utils/async_builder.dart';
import 'package:indigo_insights/utils/formatters.dart';

class StabilityPoolAccountDistributionPieChart extends StatelessWidget {
  const StabilityPoolAccountDistributionPieChart(
      {super.key, required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final styles = AppTextStyles.of(context);

    return AsyncBuilder(
      fetcher: () => Future.wait([
        sl<StabilityPoolRepository>().getPools(),
        sl<StabilityPoolAccountRepository>().getAccounts(),
      ]).then((results) {
        final pool = (results[0] as List<StabilityPool>)
            .firstWhere((e) => e.asset == asset);
        final balances = (results[1] as List<StabilityPoolAccount>)
            .where((e) => e.asset == asset)
            .map((e) {
          try {
            return pool.getAccountBalance(e);
          } catch (_) {
            return 0.0;
          }
        }).where((b) => b > 0).toList()
          ..sort((a, b) => b.compareTo(a));
        return (pool: pool, balances: balances);
      }),
      builder: (data) {
        final balances = data.balances;
        final totalSp = balances.fold(0.0, (s, b) => s + b);
        final top = balances.take(10).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SP Balance Distribution ($asset)',
                      style: styles.cardTitle),
                  Text(
                    'Total: ${numberFormatter(totalSp, 2)} $asset · ${balances.length} accounts',
                    style:
                        styles.bodySm.copyWith(color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _BarDistributionChart(
                balances: top,
                total: totalSp,
                unit: asset,
                barColor: colors.primary,
                colors: colors,
                styles: styles,
              ),
            ),
          ],
        );
      },
      errorBuilder: (error, retry) => Text(error.toString()),
    );
  }
}

// ─── Shared horizontal bar chart for distribution ─────────────────────────────

class _BarDistributionChart extends StatelessWidget {
  final List<double> balances;
  final double total;
  final String unit;
  final Color barColor;
  final AppColorScheme colors;
  final AppTextStyles styles;

  const _BarDistributionChart({
    required this.balances,
    required this.total,
    required this.unit,
    required this.barColor,
    required this.colors,
    required this.styles,
  });

  @override
  Widget build(BuildContext context) {
    if (balances.isEmpty) {
      return Center(
        child: Text('No data', style: styles.bodySm.copyWith(color: colors.textMuted)),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: balances.mapIndexed((i, bal) {
          final pct = total > 0 ? (bal / total).clamp(0.0, 1.0) : 0.0;
          final abbr = getAbbreviation(bal);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    '#${i + 1}',
                    style: styles.monoSm.copyWith(color: colors.textMuted),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            numberAbbreviatedFormatter(bal, abbr),
                            style: styles.monoSm,
                          ),
                          Text(
                            '${(pct * 100).toStringAsFixed(1)}%',
                            style: styles.monoSm
                                .copyWith(color: colors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: pct,
                          backgroundColor: colors.canvas,
                          valueColor:
                              AlwaysStoppedAnimation(barColor.withValues(alpha: 0.85)),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
