import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:indigo_insights/repositories/redemption_repository.dart';
import 'package:indigo_insights/service_locator.dart';
import 'package:indigo_insights/theme/app_color_scheme.dart';
import 'package:indigo_insights/theme/app_text_styles.dart';
import 'package:indigo_insights/utils/async_builder.dart';
import 'package:indigo_insights/utils/formatters.dart';

class RedemptionInformation extends StatelessWidget {
  const RedemptionInformation(this.asset, {super.key});

  final String asset;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final styles = AppTextStyles.of(context);

    infoRow(String title, String value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: styles.bodySm.copyWith(color: colors.textSecondary)),
              Text(value,
                  style: styles.monoSm.copyWith(color: colors.textPrimary)),
            ],
          ).animate().scaleY(duration: 300.ms, curve: Curves.easeInOut),
        );

    return AsyncBuilder(
      fetcher: () => sl<RedemptionRepository>().getRedemptionsForAsset(asset),
      builder: (redemptions) {
        redemptions.sortBy((s) => s.createdAt);

        final rewardsLast1 = redemptions
            .where(
              (s) => s.createdAt.toUtc().isAfter(
                    DateTime.now().toUtc().add(const Duration(days: -1)),
                  ),
            )
            .toList()
          ..sortBy((s) => s.createdAt);

        final rewardsLast7 = redemptions
            .where(
              (s) => s.createdAt.toUtc().isAfter(
                    DateTime.now().toUtc().add(const Duration(days: -7)),
                  ),
            )
            .toList()
          ..sortBy((s) => s.createdAt);

        final rewardsLast30 = redemptions
            .where(
              (s) => s.createdAt.toUtc().isAfter(
                    DateTime.now().toUtc().add(const Duration(days: -30)),
                  ),
            )
            .toList()
          ..sortBy((s) => s.createdAt);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$asset Redemptions', style: styles.cardTitle)
                .animate()
                .scaleY(duration: 300.ms, curve: Curves.easeInOut),
            const SizedBox(height: 16),
            infoRow(
              'Total Redeemed',
              '${numberFormatter(redemptions.map((r) => r.redeemedAmount).sum, 2)} $asset',
            ),
            Divider(color: colors.border),
            infoRow(
              'Total Returned',
              '${numberFormatter(redemptions.map((r) => r.lovelacesReturned).sum, 2)} ADA',
            ),
            Divider(color: colors.border),
            infoRow(
              'Last 24h',
              '${numberFormatter(rewardsLast1.map((r) => r.lovelacesReturned).sum, 2)} ADA',
            ),
            Divider(color: colors.border),
            infoRow(
              'Last Week',
              '${numberFormatter(rewardsLast7.map((r) => r.lovelacesReturned).sum, 2)} ADA',
            ),
            Divider(color: colors.border),
            infoRow(
              'Last Month',
              '${numberFormatter(rewardsLast30.map((r) => r.lovelacesReturned).sum, 2)} ADA',
            ),
          ],
        );
      },
      errorBuilder: (error, retry) =>
          Center(child: Text('Error: $error')),
    );
  }
}
