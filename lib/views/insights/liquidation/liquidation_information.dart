import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:indigo_insights/models/indigo_asset.dart';
import 'package:indigo_insights/repositories/liquidation_repository.dart';
import 'package:indigo_insights/service_locator.dart';
import 'package:indigo_insights/utils/async_builder.dart';
import 'package:indigo_insights/utils/formatters.dart';
import 'package:indigo_insights/theme/app_text_styles.dart';

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

        if (liquidations.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${indigoAsset.asset} Liquidations',
                style: AppTextStyles.of(context).cardTitle,
              ),
              const SizedBox(height: 32),
              const Text('No liquidations recorded for this asset.'),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${indigoAsset.asset} Liquidations',
                  style: AppTextStyles.of(context).cardTitle,
                ),
                Text(
                  numberFormatter(liquidations.length, 0),
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ).animate().scaleY(duration: 300.ms, curve: Curves.easeInOut),
            const SizedBox(height: 32),
            // Collateral differs per CDP (ADA, NIGHT, USDC…), so totals are
            // aggregated in USD using each event's recorded collateral price.
            informationRow(
              'Total Liquidated',
              assetAmount(
                liquidations.map((c) => c.collateralUsdValue).sum,
                context,
                asset: 'USD',
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
                    .map((c) => c.collateralUsdValue)
                    .reduce((value, element) => value > element ? value : element),
                context,
                asset: 'USD',
              ),
            ),
            const Divider(),
            informationRow(
              'SP Rewards (Total)',
              assetAmount(
                liquidations
                    .map((c) =>
                        c.collateralUsdValue * 0.98 - (c.burnedUsdValue ?? 0.0))
                    .fold(0.0, (a, b) => a + b),
                context,
                asset: 'USD',
              ),
            ),
            const Divider(),
            informationRow(
              'Governance Rewards (Total)',
              assetAmount(
                liquidations
                    .map((c) => c.collateralUsdValue * 0.02)
                    .fold(0.0, (a, b) => a + b),
                context,
                asset: 'USD',
              ),
            ),
          ],
        );
      },
      errorBuilder: (error, retry) => Text(error.toString()),
    );
  }
}
