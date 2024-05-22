import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/models/redemption.dart';
import 'package:indigo_insights/providers/redemption_provider.dart';
import 'package:indigo_insights/theme/gradients.dart';
import 'package:indigo_insights/utils/loader.dart';
import 'package:indigo_insights/widgets/amount_date_chart.dart';

class StakingRewardsChart extends HookConsumerWidget {
  const StakingRewardsChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    getRedemptionStakingFeesData(List<Redemption> redemptions) {
      return redemptions
          .groupFoldBy<DateTime, double>(
            (item) => DateTime(
                item.createdAt.year, item.createdAt.month, item.createdAt.day),
            (a, b) => (a ?? 0) + b.processingFeeLovelaces,
          )
          .entries
          .map((entry) => AmountDateData(entry.key, entry.value))
          .toList();
    }

    return ref.watch(redemptionsProvider).when(
        data: (accountsUnclaimedRewards) {
          final redemptionStakingFeesData =
              getRedemptionStakingFeesData(accountsUnclaimedRewards);

          return AmountDateChart(
            title: "Staking Rewards",
            currency: "ADA",
            labels: const ["Redemption Fee"],
            data: [redemptionStakingFeesData],
            colors: const [Colors.blueAccent],
            gradients: [blueGradient],
          );
        },
        error: (error, stackTrade) => Text(error.toString()),
        loading: () => const Loader());
  }
}
