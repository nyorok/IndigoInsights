import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/models/asset_price.dart';
import 'package:indigo_insights/models/cdp.dart';
import 'package:indigo_insights/models/cdps_stats.dart';
import 'package:indigo_insights/models/indigo_asset.dart';
import 'package:indigo_insights/providers/asset_price_provider.dart';
import 'package:indigo_insights/providers/cdp_provider.dart';
import 'package:indigo_insights/utils/formatters.dart';
import 'package:indigo_insights/utils/loader.dart';
import 'package:indigo_insights/utils/page_title.dart';
import 'package:indigo_insights/widgets/percentage_gain.dart';

final cdpsInformationProvider =
    FutureProvider.family<
      ({List<Cdp> cdps, AssetPrice assetPrice, List<CdpsStats> cdpsStats}),
      String
    >((ref, asset) async {
      final cdps = await ref
          .watch(cdpsProvider.future)
          .then((value) => value.where((e) => e.asset == asset).toList());

      final assetPrice = await ref
          .watch(assetPricesProvider.future)
          .then((value) => value.firstWhere((e) => e.asset == asset));

      final cdpsStats = await ref.watch(cdpsStatsProvider(asset).future);

      return (cdps: cdps, assetPrice: assetPrice, cdpsStats: cdpsStats);
    });

class CdpInformation extends HookConsumerWidget {
  const CdpInformation({super.key, required this.indigoAsset});

  final IndigoAsset indigoAsset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    calculatedAmount(
      double amount,
      BuildContext context, {
      String substring = "ADA",
    }) => Row(
      children: [
        Text(numberFormatter(amount, 2)),
        Text(
          " $substring",
          style: TextStyle(color: Theme.of(context).colorScheme.onTertiary),
        ),
      ],
    );

    informationRow(String title, Widget info) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(title), info],
    ).animate().scaleY(duration: 300.ms, curve: Curves.easeInOut);

    Widget informationRowWithTooltip(
      String title,
      Widget info,
      String tooltip,
    ) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Tooltip(
            message: tooltip,
            child: Row(
              children: [
                Text(title),
                const SizedBox(width: 4),
                const Icon(Icons.info_outline, size: 16, color: Colors.grey),
              ],
            ),
          ),
          info,
        ],
      ).animate().scaleY(duration: 300.ms, curve: Curves.easeInOut);
    }

    double calculateTopCdpsDomination(List<Cdp> cdps, int topCount) {
      // Sort CDPs by collateral amount in descending order
      final sortedCollaterals = cdps.map((c) => c.collateralAmount).toList()
        ..sort((a, b) => b.compareTo(a));

      // Sum up the collaterals for the top `topCount` CDPs
      final topCollateralsSum = sortedCollaterals
          .take(topCount)
          .reduce((value, element) => value + element);

      // Calculate the total collateral
      final totalCollateral = sortedCollaterals.reduce(
        (value, element) => value + element,
      );

      // Return the domination percentage
      return (topCollateralsSum / totalCollateral) * 100;
    }

    double calculateHHI(List<Cdp> cdps) {
      final collaterals = cdps.map((c) => c.collateralAmount).toList();
      final totalCollateral = collaterals.reduce((a, b) => a + b);

      // Avoid division by zero
      if (totalCollateral == 0) return 0;

      final hhi = collaterals
          .map((collateral) => (collateral / totalCollateral))
          .map((share) => share * share)
          .reduce((a, b) => a + b);

      return hhi;
    }

    Color getColorForHHI(double hhi) {
      if (hhi <= 0.10) return Colors.green; // Highly Diverse
      if (hhi <= 0.25) return Colors.yellow; // Moderately Concentrated
      return Colors.red; // Highly Concentrated
    }

    return ref
        .watch(cdpsInformationProvider(indigoAsset.asset))
        .when(
          data: (data) {
            final cdps = data.cdps;
            final assetPrice = data.assetPrice;
            final cdpsStats = data.cdpsStats;

            final currentCollateral = cdpsStats.last.totalCollateral;
            final yearStartCollateral = cdpsStats.first.totalCollateral;
            final lastMonthCollateral = cdpsStats
                .where(
                  (cs) => cs.time.isAfter(
                    cdpsStats.last.time.add(const Duration(days: -30)),
                  ),
                )
                .reduce((a, b) => a.time.isBefore(b.time) ? a : b)
                .totalCollateral;

            final lastDayCollateral = cdpsStats
                .where(
                  (cs) => cs.time.isAfter(
                    cdpsStats.last.time.add(const Duration(days: -1)),
                  ),
                )
                .reduce((a, b) => a.time.isBefore(b.time) ? a : b)
                .totalCollateral;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageTitle(
                  title: indigoAsset.asset,
                ).animate().scaleY(duration: 300.ms, curve: Curves.easeInOut),
                const SizedBox(height: 20),
                informationRow('Open CDPs', Text(cdps.length.toString())),
                const Divider(),
                informationRow(
                  'Collateral Ratio',
                  calculatedAmount(
                    100 *
                        cdps
                            .map((c) => (c.collateralAmount))
                            .reduce((value, element) => value + element) /
                        (cdps
                                .map((c) => (c.mintedAmount))
                                .reduce((value, element) => value + element) *
                            assetPrice.price),
                    context,
                    substring: "%",
                  ),
                ),
                const Divider(),
                informationRow(
                  'Total Collateral',
                  calculatedAmount(
                    cdps
                        .map((c) => (c.collateralAmount))
                        .reduce((value, element) => value + element),
                    context,
                  ),
                ),
                const Divider(),
                informationRow(
                  'Total Minted',
                  calculatedAmount(
                    (cdps
                        .map((c) => (c.mintedAmount))
                        .reduce((value, element) => value + element)),
                    context,
                    substring: indigoAsset.asset,
                  ),
                ),
                const Divider(),
                informationRow(
                  'Collateral Change (Last 24h)',
                  PercentageGain(lastDayCollateral, currentCollateral),
                ),
                const Divider(),
                informationRow(
                  'Collateral Change (Last Month)',
                  PercentageGain(lastMonthCollateral, currentCollateral),
                ),
                const Divider(),
                informationRow(
                  'Collateral Change (YTD)',
                  PercentageGain(yearStartCollateral, currentCollateral),
                ),
                const Divider(),
                informationRow(
                  'Collateral Held by Largest 10 CDPs',
                  calculatedAmount(
                    calculateTopCdpsDomination(cdps, 10),
                    context,
                    substring: "%",
                  ),
                ),
                const Divider(),
                informationRowWithTooltip(
                  'Collateral Distribution (HHI)',
                  Text(
                    calculateHHI(cdps).toStringAsFixed(2),
                    style: TextStyle(color: getColorForHHI(calculateHHI(cdps))),
                  ),
                  'HHI measures concentration:\n- 0 to 0.10: Highly Diverse (Green)\n- 0.10 to 0.25: Moderately Concentrated (Yellow)\n- > 0.25: Highly Concentrated (Red)',
                ),
              ],
            );
          },
          error: (error, stackTrace) => Text(error.toString()),
          loading: () => const SizedBox(height: 20, child: Loader()),
        );
  }
}
