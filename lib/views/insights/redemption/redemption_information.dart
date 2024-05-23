import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/models/redemption.dart';
import 'package:indigo_insights/utils/formatters.dart';
import 'package:indigo_insights/utils/page_title.dart';

class RedemptionInformation extends HookConsumerWidget {
  const RedemptionInformation(this.asset, this.redemptions, {super.key});

  final String asset;
  final List<Redemption> redemptions;

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    redemptions.sortBy((s) => s.createdAt);
    final rewardsLast1 = redemptions
        .where((s) => s.createdAt
            .toUtc()
            .isAfter(DateTime.now().toUtc().add(const Duration(days: -1))))
        .toList();
    rewardsLast1.sortBy((s) => s.createdAt);

    final rewardsLast7 = redemptions
        .where((s) => s.createdAt
            .toUtc()
            .isAfter(DateTime.now().toUtc().add(const Duration(days: -7))))
        .toList();
    rewardsLast7.sortBy((s) => s.createdAt);

    final rewardsLast30 = redemptions
        .where((s) => s.createdAt
            .toUtc()
            .isAfter(DateTime.now().toUtc().add(const Duration(days: -30))))
        .toList();
    rewardsLast30.sortBy((s) => s.createdAt);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      PageTitle(title: "$asset Redemptions"),
      const SizedBox(height: 20),
      informationRow('Total Redemptions',
          adaAmount(redemptions.map((r) => r.lovelacesReturned).sum, context)),
      informationRow('Redemptions (Last 24h)',
          adaAmount(rewardsLast1.map((r) => r.lovelacesReturned).sum, context)),
      informationRow('Redemptions (Last Week)',
          adaAmount(rewardsLast7.map((r) => r.lovelacesReturned).sum, context)),
      informationRow(
          'Redemptions (Last Month)',
          adaAmount(
              rewardsLast30.map((r) => r.lovelacesReturned).sum, context)),
    ]);
  }
}
