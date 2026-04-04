import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:indigo_insights/repositories/stake_history_repository.dart';
import 'package:indigo_insights/service_locator.dart';
import 'package:indigo_insights/utils/async_builder.dart';
import 'package:indigo_insights/utils/formatters.dart';
import 'package:indigo_insights/theme/app_text_styles.dart';

class StakingInformation extends StatelessWidget {
  const StakingInformation({super.key});

  @override
  Widget build(BuildContext context) {
    indyAmount(double amount, BuildContext context) => Row(
      children: [
        Text(numberFormatter(amount, 2)),
        Text(
          ' INDY',
          style: TextStyle(color: Theme.of(context).colorScheme.onTertiary),
        ),
      ],
    );

    informationRow(String title, Widget info) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(title), info],
    ).animate().scaleY(duration: 300.ms, curve: Curves.easeInOut);

    return AsyncBuilder(
      fetcher: () => sl<StakeHistoryRepository>().getHistory(),
      builder: (stakeHistory) {
        stakeHistory.sortBy((s) => s.date);
        final stakedLast1 = stakeHistory
            .where(
              (s) => s.date.isAfter(
                DateTime.now().add(const Duration(days: -1)),
              ),
            )
            .toList()
          ..sortBy((s) => s.date);

        final stakedLast7 = stakeHistory
            .where(
              (s) => s.date.isAfter(
                DateTime.now().add(const Duration(days: -7)),
              ),
            )
            .toList()
          ..sortBy((s) => s.date);

        final stakedLast30 = stakeHistory
            .where(
              (s) => s.date.isAfter(
                DateTime.now().add(const Duration(days: -30)),
              ),
            )
            .toList()
          ..sortBy((s) => s.date);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Indy Staking',
                    style: AppTextStyles.of(context).cardTitle)
                .animate().scaleY(duration: 300.ms, curve: Curves.easeInOut),
            const SizedBox(height: 20),
            informationRow(
              'Total Staked',
              indyAmount(stakeHistory.last.staked, context),
            ),
            informationRow(
              'Staked (Last 24h)',
              indyAmount(
                stakedLast1.last.staked - stakedLast1.first.staked,
                context,
              ),
            ),
            informationRow(
              'Staked (Last Week)',
              indyAmount(
                stakedLast7.last.staked - stakedLast7.first.staked,
                context,
              ),
            ),
            informationRow(
              'Staked (Last Month)',
              indyAmount(
                stakedLast30.last.staked - stakedLast30.first.staked,
                context,
              ),
            ),
          ],
        );
      },
      errorBuilder: (error, retry) => Text(error.toString()),
    );
  }
}
