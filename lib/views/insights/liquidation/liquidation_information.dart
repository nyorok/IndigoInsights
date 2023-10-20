import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/models/indigo_asset.dart';
import 'package:indigo_insights/models/liquidation.dart';
import 'package:indigo_insights/providers/liquidation_provider.dart';
import 'package:indigo_insights/utils/formatters.dart';
import 'package:indigo_insights/utils/loader.dart';
import 'package:indigo_insights/utils/page_title.dart';

final assetLiquidationProvider =
    FutureProvider.family<List<Liquidation>, String>((ref, asset) async {
  final liquidations = await ref
      .watch(liquidationProvider.future)
      .then((value) => value.where((e) => e.asset == asset).toList());

  return liquidations;
});

class LiquidationInformation extends HookConsumerWidget {
  const LiquidationInformation({super.key, required this.indigoAsset});

  final IndigoAsset indigoAsset;

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

    return ref.watch(assetLiquidationProvider(indigoAsset.asset)).when(
          data: (liquidations) {
            liquidations.sortBy((liq) => liq.createdAt);

            final liquidationsDuration =
                DateTime.now().difference(liquidations.first.createdAt);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PageTitle(title: "${indigoAsset.asset} Liquidations"),
                    Text(
                      numberFormatter(liquidations.length, 0),
                      style: const TextStyle(fontSize: 18),
                    )
                  ],
                ),
                const SizedBox(height: 32),
                informationRow(
                    'Total Liquidated',
                    adaAmount(liquidations.map((c) => c.collateralAbsorbed).sum,
                        context)),
                const Divider(),
                informationRow(
                    'Biggest Liquidation',
                    adaAmount(
                        liquidations.map((c) => c.collateralAbsorbed).reduce(
                            (value, element) =>
                                value > element ? value : element),
                        context)),
                const Divider(),
                informationRow(
                    'SP ADA Rewards (Total)',
                    adaAmount(
                        liquidations
                            .map((c) => (c.collateralAbsorbed * 0.98 -
                                c.iAssetBurned * c.oraclePrice))
                            .reduce((value, element) => value + element),
                        context)),
                const Divider(),
                informationRow(
                    'SP ADA Rewards (Average per Day)',
                    adaAmount(
                        liquidations
                                .map((c) => (c.collateralAbsorbed * 0.98 -
                                    c.iAssetBurned * c.oraclePrice))
                                .reduce((value, element) => value + element) /
                            liquidationsDuration.inDays,
                        context)),
                const Divider(),
                informationRow(
                    'Governance ADA Rewards (Total)',
                    adaAmount(
                        liquidations
                            .map((c) => c.collateralAbsorbed * 0.02)
                            .reduce((value, element) => value + element),
                        context)),
                const Divider(),
                informationRow(
                    'Governance ADA Rewards (Average per Day)',
                    adaAmount(
                        liquidations
                                .map((c) => c.collateralAbsorbed * 0.02)
                                .reduce((value, element) => value + element) /
                            liquidationsDuration.inDays,
                        context)),
              ],
            );
          },
          error: (error, stackTrace) => Text(error.toString()),
          loading: () => const Loader(),
        );
  }
}
