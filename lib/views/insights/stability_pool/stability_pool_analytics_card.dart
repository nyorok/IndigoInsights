import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:indigo_insights/models/asset_status.dart';
import 'package:indigo_insights/models/indigo_asset.dart';
import 'package:indigo_insights/models/stability_pool.dart';
import 'package:indigo_insights/models/stability_pool_account.dart';
import 'package:indigo_insights/repositories/asset_status_repository.dart';
import 'package:indigo_insights/repositories/stability_pool_account_repository.dart';
import 'package:indigo_insights/repositories/stability_pool_repository.dart';
import 'package:indigo_insights/service_locator.dart';
import 'package:indigo_insights/theme/app_color_scheme.dart';
import 'package:indigo_insights/theme/app_text_styles.dart';
import 'package:indigo_insights/utils/async_builder.dart';
import 'package:indigo_insights/utils/formatters.dart';

typedef _SpAnalyticsData = ({
  StabilityPool pool,
  double totalSupply,
  List<StabilityPoolAccount> accounts,
});

class StabilityPoolAnalyticsCard extends StatelessWidget {
  final IndigoAsset indigoAsset;
  const StabilityPoolAnalyticsCard({super.key, required this.indigoAsset});

  @override
  Widget build(BuildContext context) {
    return AsyncBuilder<_SpAnalyticsData>(
      fetcher: () async {
        final results = await Future.wait([
          sl<StabilityPoolRepository>().getPools(),
          sl<AssetStatusRepository>().getStatuses(),
          sl<StabilityPoolAccountRepository>().getAccounts(),
        ]);
        final pools = results[0] as List<StabilityPool>;
        final statuses = results[1] as List<AssetStatus>;
        final accounts = results[2] as List<StabilityPoolAccount>;

        final pool = pools.firstWhere((p) => p.asset == indigoAsset.asset);
        final totalSupply = statuses
            .firstWhere((s) => s.asset == indigoAsset.asset)
            .totalSupply;
        final assetAccounts =
            accounts.where((a) => a.asset == indigoAsset.asset).toList();

        return (pool: pool, totalSupply: totalSupply, accounts: assetAccounts);
      },
      builder: (data) => _AnalyticsContent(
        data: data,
        asset: indigoAsset.asset,
      ),
      errorBuilder: (error, retry) => Text(error.toString()),
    );
  }
}

class _AnalyticsContent extends StatelessWidget {
  final _SpAnalyticsData data;
  final String asset;
  const _AnalyticsContent({required this.data, required this.asset});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final styles = AppTextStyles.of(context);
    final pool = data.pool;
    final accounts = data.accounts;
    final totalSp = pool.totalAmount;

    final balances = accounts.map((a) {
      try {
        return pool.getAccountBalance(a);
      } catch (_) {
        return 0.0;
      }
    }).where((b) => b > 0).sortedByCompare<double>((b) => b, (a, b) => b.compareTo(a)).toList();

    final top10Sum = balances.take(10).fold(0.0, (s, b) => s + b);
    final top10Pct = totalSp > 0 ? (top10Sum / totalSp) * 100 : 0.0;

    double totalUnclaimed = 0;
    for (final a in accounts) {
      try {
        totalUnclaimed += pool.getAccountUnclaimedRewards(a);
      } catch (_) {}
    }

    final abbr = getAbbreviation(totalSp);
    final unclaimedAbbr = getAbbreviation(totalUnclaimed);

    infoRow(String title, String value, {Color? valueColor}) =>
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: styles.bodySm.copyWith(color: colors.textSecondary)),
              Text(
                value,
                style: styles.monoSm.copyWith(
                  color: valueColor ?? colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ).animate().scaleY(duration: 300.ms, curve: Curves.easeInOut),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$asset Stability Pool', style: styles.cardTitle)
            .animate()
            .scaleY(duration: 300.ms, curve: Curves.easeInOut),
        const SizedBox(height: 16),

        infoRow('Total Deposits', '${numberAbbreviatedFormatter(totalSp, abbr)} $asset'),
        Divider(color: colors.border),
        infoRow(
          'Supply Deposited',
          data.totalSupply > 0
              ? '${(totalSp / data.totalSupply * 100).toStringAsFixed(1)}%'
              : '—',
        ),
        Divider(color: colors.border, height: 24),
        infoRow('Total Accounts', '${accounts.length}'),
        Divider(color: colors.border),
        infoRow(
          'Top 10 Hold',
          '${top10Pct.toStringAsFixed(1)}%',
          valueColor: top10Pct > 50 ? colors.warning : colors.success,
        ),
        Divider(color: colors.border),
        infoRow(
          'Unclaimed ADA',
          '${numberAbbreviatedFormatter(totalUnclaimed, unclaimedAbbr)} ADA',
          valueColor: colors.primary,
        ),

        if (balances.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            'Top 5 Holders (% of pool)',
            style: styles.sectionLabel.copyWith(color: colors.textMuted),
          ),
          const SizedBox(height: 6),
          ...balances.take(5).mapIndexed((i, bal) {
            final pct = totalSp > 0 ? (bal / totalSp).clamp(0.0, 1.0) : 0.0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('#${i + 1}',
                          style: styles.sectionLabel
                              .copyWith(color: colors.textMuted)),
                      Text(
                        '${(pct * 100).toStringAsFixed(1)}%',
                        style: styles.monoSm,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: colors.canvas,
                      valueColor:
                          AlwaysStoppedAnimation(colors.primary.withValues(alpha: 0.8)),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }
}
