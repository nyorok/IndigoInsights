import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/models/indigo_asset.dart';
import 'package:indigo_insights/providers/cdp_provider.dart';
import 'package:indigo_insights/utils/formatters.dart';
import 'package:indigo_insights/utils/loader.dart';
import 'package:indigo_insights/utils/page_title.dart';
import 'package:indigo_insights/widgets/percentage_gain.dart';

class MintedSupplyInformation extends HookConsumerWidget {
  const MintedSupplyInformation({super.key, required this.indigoAsset});

  final IndigoAsset indigoAsset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Helper to format asset amounts with styling
    assetAmount(double amount, String currency, BuildContext context) => Row(
          children: [
            Text(
              numberFormatter(amount, 2),
            ),
            Text(
              " $currency",
              style: TextStyle(color: Theme.of(context).colorScheme.onTertiary),
            ),
          ],
        );

    // Helper for displaying title and information in a row
    informationRow(String title, Widget info) =>
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(title),
          info,
        ]);

    // Watch the cdpsStatsProvider with the indigoAsset.asset as input
    return ref.watch(cdpsStatsProvider(indigoAsset.asset)).when(
          data: (cdpsStats) {
            // Calculate total minted and total collateral from cdpsStats
            final currentMinted = cdpsStats.last.totalMinted;
            final yearStartMinted = cdpsStats.first.totalMinted;
            final lastMonthMinted = cdpsStats
                .where((cs) => cs.time.isAfter(
                    cdpsStats.last.time.add(const Duration(days: -30))))
                .reduce((a, b) => a.time.isBefore(b.time) ? a : b)
                .totalMinted;

            final lastDayMinted = cdpsStats
                .where((cs) => cs.time
                    .isAfter(cdpsStats.last.time.add(const Duration(days: -1))))
                .reduce((a, b) => a.time.isBefore(b.time) ? a : b)
                .totalMinted;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageTitle(title: indigoAsset.asset),
                const SizedBox(height: 32),
                informationRow(
                  'Total Minted Supply',
                  assetAmount(currentMinted, indigoAsset.asset, context),
                ),
                const Divider(),
                informationRow(
                  'Minted Change (Last 24h)',
                  PercentageGain(lastDayMinted, currentMinted),
                ),
                const Divider(),
                informationRow(
                  'Minted Change (Last Month)',
                  PercentageGain(lastMonthMinted, currentMinted),
                ),
                const Divider(),
                informationRow(
                  'Minted Change (YTD)',
                  PercentageGain(yearStartMinted, currentMinted),
                ),
              ],
            );
          },
          error: (error, stackTrace) => Text(error.toString()),
          loading: () => const Loader(),
        );
  }
}
