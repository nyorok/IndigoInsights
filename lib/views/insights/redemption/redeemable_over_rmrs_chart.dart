import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';
import 'package:indigo_insights/models/asset_price.dart';
import 'package:indigo_insights/models/asset_status.dart';
import 'package:indigo_insights/models/cdp.dart';
import 'package:indigo_insights/models/indigo_asset.dart';
import 'package:indigo_insights/repositories/asset_price_repository.dart';
import 'package:indigo_insights/repositories/asset_status_repository.dart';
import 'package:indigo_insights/repositories/cdp_repository.dart';
import 'package:indigo_insights/service_locator.dart';
import 'package:indigo_insights/theme/gradients.dart';
import 'package:indigo_insights/utils/async_builder.dart';
import 'package:indigo_insights/utils/collateral_prices.dart';
import 'package:indigo_insights/widgets/percentage_amount_chart.dart';

/// [collateralPrice] is the iAsset price expressed in the CDP's own collateral
/// token (ADA, NIGHT, …). Using each CDP's pair price keeps collateral and
/// debt in the same unit; the result is in iAsset units.
double calculateRedeemableAmount(Cdp cdp, double rmr, double collateralPrice) {
  final ratio = cdp.collateralAmount / (collateralPrice * cdp.mintedAmount);
  if (rmr <= ratio) return 0;
  return ((-cdp.collateralAmount / collateralPrice) + rmr * cdp.mintedAmount) /
      (rmr - 1);
}

class RedeemableOverRmrsChart extends StatelessWidget {
  const RedeemableOverRmrsChart(this.indigoAsset, {super.key});

  final IndigoAsset indigoAsset;

  List<PercentageAmountData> _getRedeemableOverRmrsData(
    List<Cdp> cdps,
    CollateralPrices prices,
    List<double> rmrs,
  ) {
    final redeemablePerCdp = cdps
        .map((e) {
          final price = prices.priceFor(indigoAsset.asset, e.collateralAsset);
          // Skip CDPs whose collateral pair has no oracle price — mixing
          // units would corrupt the aggregate.
          if (price == null || price <= 0) {
            return const Iterable<PercentageAmountData>.empty();
          }
          return rmrs.map(
            (rmr) => PercentageAmountData(
              rmr,
              calculateRedeemableAmount(e, rmr / 100, price),
            ),
          );
        })
        .expand((e) => e)
        .where((e) => e.amount.abs() > 0)
        .toList();

    final data = redeemablePerCdp
        .groupFoldBy<double, double>(
          (item) => item.percentage,
          (a, b) => (a ?? 0) + b.amount,
        )
        .entries
        .map((entry) => PercentageAmountData(entry.key, entry.value))
        .toList()
      ..sort((a, b) => a.percentage.compareTo(b.percentage));

    return data;
  }

  @override
  Widget build(BuildContext context) {
    final rmrs = List.generate(100, (index) => 150 + index * 5.0);

    return AsyncBuilder(
      fetcher: () => Future.wait([
        sl<CdpRepository>().getCdps(),
        sl<AssetPriceRepository>().getPrices(),
        sl<AssetStatusRepository>().getStatuses(),
      ]).then((results) {
        final cdps = (results[0] as List<Cdp>)
            .where((e) => e.asset == indigoAsset.asset)
            .toList();
        // `/api/asset-prices` does not publish every (iAsset, collateral) pair
        // — iUSD/ADA, which backs most iUSD CDPs, is regularly missing.
        // CollateralPrices fills those gaps with a USD cross-rate instead of
        // dropping the positions.
        final prices = CollateralPrices.from(
          results[2] as List<AssetStatus>,
          results[1] as List<AssetPrice>,
        );
        return (cdps: cdps, prices: prices);
      }),
      builder: (data) {
        return PercentageAmountChart(
          title: 'Redeemable over RMRs${indigoAsset.rmr != null ? ' (${indigoAsset.rmr}%)' : ''}',
          currency: indigoAsset.asset,
          labels: [indigoAsset.asset],
          mintedSupply: data.cdps.map((e) => e.mintedAmount).sum,
          data: [
            _getRedeemableOverRmrsData(data.cdps, data.prices, rmrs)
          ],
          colors: [getColorByAsset(indigoAsset.asset)],
          gradients: [getGradientByAsset(indigoAsset.asset)],
        );
      },
      errorBuilder: (error, retry) => Center(child: Text('Error: $error')),
    );
  }
}
