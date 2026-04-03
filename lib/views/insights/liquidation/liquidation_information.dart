import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:indigo_insights/models/indigo_asset.dart';
import 'package:indigo_insights/repositories/liquidation_repository.dart';
import 'package:indigo_insights/service_locator.dart';
import 'package:indigo_insights/utils/async_builder.dart';
import 'package:indigo_insights/utils/formatters.dart';
import 'package:indigo_insights/utils/page_title.dart';

class LiquidationInformation extends StatelessWidget {
  const LiquidationInformation({super.key, required this.indigoAsset});

  final IndigoAsset indigoAsset;

  @override
  Widget build(BuildContext context) {
    assetAmount(double amount, BuildContext context, {String asset = 'ADA'}) => Row(
      children: [
        Text(numberFormatter(amount, 2)),
        Text(
          ' $asset',
          style: TextStyle(color: Theme.of(context).colorScheme.onTertiary),
        ),
      ],
    );

    informationRow(String title, Widget info) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(title), info],
    ).animate().scaleY(duration: 300.ms, curve: Curves.easeInOut);

    return AsyncBuilder(
      fetcher: () => sl<LiquidationRepository>().getLiquidationsForAsset(indigoAsset.asset),
      builder: (liquidations) {
        liquidations.sortBy((liq) => liq.createdAt);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PageTitle(title: '${indigoAsset.asset} Liquidations'),
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
                    .reduce((value, element) => value > element ? value : element),
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
                          (c.collateralAbsorbed * 0.98 - c.iAssetBurned * c.oraclePrice),
                    )
                    .reduce((value, element) => value + element),
                context,
              ),
            ),
            const Divider(),
            informationRow(
              'Governance ADA Rewards (Total)',
              assetAmount(
                liquidations.map((c) => c.collateralAbsorbed * 0.02).reduce((a, b) => a + b),
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
