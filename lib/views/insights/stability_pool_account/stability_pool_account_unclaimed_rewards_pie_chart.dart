import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';
import 'package:indigo_insights/models/stability_pool.dart';
import 'package:indigo_insights/models/stability_pool_account.dart';
import 'package:indigo_insights/repositories/stability_pool_account_repository.dart';
import 'package:indigo_insights/repositories/stability_pool_repository.dart';
import 'package:indigo_insights/service_locator.dart';
import 'package:indigo_insights/theme/app_color_scheme.dart';
import 'package:indigo_insights/theme/app_text_styles.dart';
import 'package:indigo_insights/utils/async_builder.dart';
import 'package:indigo_insights/utils/formatters.dart';

class StabilityPoolAccountUnclaimedRewardsPieChart extends StatelessWidget {
  const StabilityPoolAccountUnclaimedRewardsPieChart({
    super.key,
    required this.asset,
  });

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
        // One entry per (account, collateral) — rewards of different
        // collateral tokens are kept apart, never summed together.
        final entries = <({String collateral, double amount})>[];
        for (final account in (results[1] as List<StabilityPoolAccount>)
            .where((e) => e.asset == asset)) {
          try {
            pool.getAccountUnclaimedRewardsByCollateral(account).forEach(
                (collateral, amount) =>
                    entries.add((collateral: collateral, amount: amount)));
          } catch (_) {
            // Skip accounts with inconsistent snapshot data.
          }
        }
        // ADA stream first, then other collaterals; largest first within each.
        entries.sort((a, b) {
          if (a.collateral != b.collateral) {
            if (a.collateral.isEmpty) return -1;
            if (b.collateral.isEmpty) return 1;
            return a.collateral.compareTo(b.collateral);
          }
          return b.amount.compareTo(a.amount);
        });
        return entries;
      }),
      builder: (entries) {
        final totalsByCollateral = <String, double>{};
        for (final e in entries) {
          totalsByCollateral[e.collateral] =
              (totalsByCollateral[e.collateral] ?? 0) + e.amount;
        }
        final totalLabel = totalsByCollateral.isEmpty
            ? '0.00 ADA'
            : totalsByCollateral.entries
                .map((e) =>
                    '${numberFormatter(e.value, 2)} ${collateralLabel(e.key)}')
                .join(' · ');
        final top = entries.take(10).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Unclaimed Rewards ($asset)',
                      style: styles.cardTitle),
                  Text(
                    'Total: $totalLabel · ${entries.length} accounts',
                    style:
                        styles.bodySm.copyWith(color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _BarRewardsChart(
                rewards: top,
                totalsByCollateral: totalsByCollateral,
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

class _BarRewardsChart extends StatelessWidget {
  final List<({String collateral, double amount})> rewards;
  final Map<String, double> totalsByCollateral;
  final AppColorScheme colors;
  final AppTextStyles styles;

  const _BarRewardsChart({
    required this.rewards,
    required this.totalsByCollateral,
    required this.colors,
    required this.styles,
  });

  @override
  Widget build(BuildContext context) {
    if (rewards.isEmpty) {
      return Center(
        child: Text('No unclaimed rewards',
            style: styles.bodySm.copyWith(color: colors.textMuted)),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: rewards.mapIndexed((i, rew) {
          // Share of this collateral's own total — different collateral
          // tokens are never compared against each other.
          final total = totalsByCollateral[rew.collateral] ?? 0.0;
          final pct = total > 0 ? (rew.amount / total).clamp(0.0, 1.0) : 0.0;
          final abbr = getAbbreviation(rew.amount);
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
                            '${numberAbbreviatedFormatter(rew.amount, abbr)} ${collateralLabel(rew.collateral)}',
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
                          valueColor: AlwaysStoppedAnimation(
                              colors.success.withValues(alpha: 0.85)),
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
