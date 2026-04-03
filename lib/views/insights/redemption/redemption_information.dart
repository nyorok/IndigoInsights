import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:indigo_insights/repositories/redemption_repository.dart';
import 'package:indigo_insights/service_locator.dart';
import 'package:indigo_insights/utils/async_builder.dart';
import 'package:indigo_insights/utils/formatters.dart';
import 'package:indigo_insights/utils/page_title.dart';

class RedemptionInformation extends StatelessWidget {
  const RedemptionInformation(this.asset, {super.key});

  final String asset;

  Widget _tokenAmount(double amount, BuildContext context, {String token = 'ADA'}) =>
      Row(
        children: [
          Text(numberFormatter(amount, 2)),
          Text(
            ' $token',
            style: TextStyle(color: Theme.of(context).colorScheme.onTertiary),
          ),
        ],
      );

  Widget _informationRow(String title, Widget info) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [Text(title), info],
  ).animate().scaleY(duration: 300.ms, curve: Curves.easeInOut);

  @override
  Widget build(BuildContext context) {
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
            PageTitle(
              title: '$asset Redemptions',
            ).animate().scaleY(duration: 300.ms, curve: Curves.easeInOut),
            const SizedBox(height: 20),
            _informationRow(
              'Total Redeemed',
              _tokenAmount(
                redemptions.map((r) => r.redeemedAmount).sum,
                context,
                token: asset,
              ),
            ),
            const SizedBox(height: 5),
            _informationRow(
              'Total Returned',
              _tokenAmount(
                redemptions.map((r) => r.lovelacesReturned).sum,
                context,
              ),
            ),
            _informationRow(
              'Last 24h',
              _tokenAmount(
                rewardsLast1.map((r) => r.lovelacesReturned).sum,
                context,
              ),
            ),
            _informationRow(
              'Last Week',
              _tokenAmount(
                rewardsLast7.map((r) => r.lovelacesReturned).sum,
                context,
              ),
            ),
            _informationRow(
              'Last Month',
              _tokenAmount(
                rewardsLast30.map((r) => r.lovelacesReturned).sum,
                context,
              ),
            ),
          ],
        );
      },
      errorBuilder: (error, retry) => Center(child: Text('Error: $error')),
    );
  }
}
