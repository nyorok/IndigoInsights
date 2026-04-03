import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:indigo_insights/models/asset_status.dart';
import 'package:indigo_insights/models/indigo_asset.dart';
import 'package:indigo_insights/models/stability_pool.dart';
import 'package:indigo_insights/repositories/asset_status_repository.dart';
import 'package:indigo_insights/repositories/stability_pool_repository.dart';
import 'package:indigo_insights/service_locator.dart';
import 'package:indigo_insights/utils/async_builder.dart';
import 'package:indigo_insights/utils/formatters.dart';
import 'package:indigo_insights/utils/page_title.dart';

class StabilityPoolInformation extends StatelessWidget {
  const StabilityPoolInformation({super.key, required this.indigoAsset});

  final IndigoAsset indigoAsset;

  @override
  Widget build(BuildContext context) {
    assetAmount(double amount, String currency, BuildContext context) => Row(
      children: [
        Text(numberFormatter(amount, 2)),
        Text(
          ' $currency',
          style: TextStyle(color: Theme.of(context).colorScheme.onTertiary),
        ),
      ],
    );

    informationRow(String title, Widget info) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(title), info],
    ).animate().scaleY(duration: 300.ms, curve: Curves.easeInOut);

    return AsyncBuilder(
      fetcher: () => Future.wait([
        sl<StabilityPoolRepository>().getPools(),
        sl<AssetStatusRepository>().getStatuses(),
      ]).then((results) {
        final stabilityPool = (results[0] as List<StabilityPool>)
            .firstWhere((e) => e.asset == indigoAsset.asset);
        final totalSupply = (results[1] as List<AssetStatus>)
            .firstWhere((e) => e.asset == indigoAsset.asset)
            .totalSupply;
        return (stabilityPool: stabilityPool, totalSupply: totalSupply);
      }),
      builder: (data) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageTitle(
              title: '${indigoAsset.asset} Stability Pool',
            ).animate().scaleY(duration: 300.ms, curve: Curves.easeInOut),
            const SizedBox(height: 32),
            informationRow(
              'Total Deposits',
              assetAmount(
                data.stabilityPool.totalAmount,
                indigoAsset.asset,
                context,
              ),
            ),
            const Divider(),
            informationRow(
              'Total Supply Deposited',
              assetAmount(
                data.stabilityPool.totalAmount / data.totalSupply * 100,
                '%',
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
