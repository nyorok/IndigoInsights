import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
    assetAmount(double amount, BuildContext context, {String asset = "ADA"}) =>
        Row(
          children: [
            Text(numberFormatter(amount, 2)),
            Text(
              " $asset",
              style: TextStyle(color: Theme.of(context).colorScheme.onTertiary),
            ),
          ],
        );

    informationRow(String title, Widget info) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(title), info],
    ).animate().scaleY(duration: 300.ms, curve: Curves.easeInOut);

    return ref
        .watch(assetLiquidationProvider(indigoAsset.asset))
        .when(
          data: (liquidations) {
            liquidations.sortBy((liq) => liq.createdAt);

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
                    ),
                  ],
                ).animate().scaleY(duration: 300.ms, curve: Curves.easeInOut),
                const SizedBox(height: 32),
                informationRow(
                  'Total Liquidated',
                  assetAmount(
                    liquidations.map((c) => c.collateralAbsorbed).sum,
                    context,
                  ),
                ),
                const Divider(),
                informationRow(
                  'Total iAssets Burned',
                  assetAmount(
                    liquidations.map((c) => c.iAssetBurned).sum,
                    context,
                    asset: indigoAsset.asset,
                  ),
                ),
                const Divider(),
                informationRow(
                  'Biggest Liquidation',
                  assetAmount(
                    liquidations
                        .map((c) => c.collateralAbsorbed)
                        .reduce(
                          (value, element) => value > element ? value : element,
                        ),
                    context,
                  ),
                ),
                const Divider(),
                informationRow(
                  'SP ADA Rewards (Total)',
                  assetAmount(
                    liquidations
                        .map(
                          (c) =>
                              (c.collateralAbsorbed * 0.98 -
                              c.iAssetBurned * c.oraclePrice),
                        )
                        .reduce((value, element) => value + element),
                    context,
                  ),
                ),
                const Divider(),
                informationRow(
                  'Governance ADA Rewards (Total)',
                  assetAmount(
                    liquidations
                        .map((c) => c.collateralAbsorbed * 0.02)
                        .reduce((value, element) => value + element),
                    context,
                  ),
                ),
              ],
            );
          },
          error: (error, stackTrace) => Text(error.toString()),
          loading: () => const SizedBox(height: 20, child: Loader()),
        );
  }
}
