import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/providers/redemption_provider.dart';
import 'package:indigo_insights/utils/formatters.dart';
import 'package:indigo_insights/utils/page_title.dart';

class RedemptionInformation extends HookConsumerWidget {
  const RedemptionInformation(this.asset, {super.key});

  final String asset;

  tokenAmount(double amount, BuildContext context, {String token = 'ADA'}) =>
      Row(
        children: [
          Text(
            numberFormatter(amount, 2),
          ),
          Text(
            " $token",
            style: TextStyle(color: Theme.of(context).colorScheme.onTertiary),
          ),
        ],
      );

  informationRow(String title, Widget info) =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title),
        info,
      ]);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(redemptionsProvider(asset)).when(
          data: (redemptions) {
            redemptions.sortBy((s) => s.createdAt);

            final rewardsLast1 = redemptions
                .where((s) => s.createdAt.toUtc().isAfter(
                    DateTime.now().toUtc().add(const Duration(days: -1))))
                .toList();
            rewardsLast1.sortBy((s) => s.createdAt);

            final rewardsLast7 = redemptions
                .where((s) => s.createdAt.toUtc().isAfter(
                    DateTime.now().toUtc().add(const Duration(days: -7))))
                .toList();
            rewardsLast7.sortBy((s) => s.createdAt);

            final rewardsLast30 = redemptions
                .where((s) => s.createdAt.toUtc().isAfter(
                    DateTime.now().toUtc().add(const Duration(days: -30))))
                .toList();
            rewardsLast30.sortBy((s) => s.createdAt);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageTitle(title: "$asset Redemptions"),
                const SizedBox(height: 20),
                informationRow(
                    'Total Redeemed',
                    tokenAmount(
                        redemptions.map((r) => r.redeemedAmount).sum, context,
                        token: asset)),
                const SizedBox(height: 5),
                informationRow(
                    'Total Returned',
                    tokenAmount(redemptions.map((r) => r.lovelacesReturned).sum,
                        context)),
                informationRow(
                    'Last 24h',
                    tokenAmount(
                        rewardsLast1.map((r) => r.lovelacesReturned).sum,
                        context)),
                informationRow(
                    'Last Week',
                    tokenAmount(
                        rewardsLast7.map((r) => r.lovelacesReturned).sum,
                        context)),
                informationRow(
                    'Last Month',
                    tokenAmount(
                        rewardsLast30.map((r) => r.lovelacesReturned).sum,
                        context)),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Error: $error')),
        );
  }
}
