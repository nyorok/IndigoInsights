import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/providers/redemption_provider.dart';
import 'package:indigo_insights/utils/formatters.dart';
import 'package:indigo_insights/utils/loader.dart';
import 'package:indigo_insights/utils/page_title.dart';

class StakingRewardsInformation extends HookConsumerWidget {
  const StakingRewardsInformation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    adaAmount(double amount, BuildContext context) => Row(
          children: [
            Text(
              numberFormatter(amount, 2),
            ),
            Text(
              " ADA",
              style: TextStyle(color: Theme.of(context).colorScheme.onTertiary),
            ),
          ],
        );

    informationRow(String title, Widget info) =>
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(title),
          info,
        ]);

    return ref.watch(redemptionsProvider).when(
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
                const PageTitle(title: "Staking Rewards"),
                const SizedBox(height: 20),
                informationRow(
                    'Total Redemption Rewards',
                    adaAmount(
                        redemptions.map((r) => r.processingFeeLovelaces).sum,
                        context)),
                informationRow(
                    'Redemption Rewards (Last 24h)',
                    adaAmount(
                        rewardsLast1.map((r) => r.processingFeeLovelaces).sum,
                        context)),
                informationRow(
                    'Redemption Rewards (Last Week)',
                    adaAmount(
                        rewardsLast7.map((r) => r.processingFeeLovelaces).sum,
                        context)),
                informationRow(
                    'Redemption Rewards (Last Month)',
                    adaAmount(
                        rewardsLast30.map((r) => r.processingFeeLovelaces).sum,
                        context)),
              ],
            );
          },
          error: (error, stackTrace) => Text(error.toString()),
          loading: () => const Loader(),
        );
  }
}
