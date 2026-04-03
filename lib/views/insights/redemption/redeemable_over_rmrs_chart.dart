import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:indigo_insights/models/asset_price.dart';
import 'package:indigo_insights/models/cdp.dart';
import 'package:indigo_insights/models/indigo_asset.dart';
import 'package:indigo_insights/repositories/asset_price_repository.dart';
import 'package:indigo_insights/repositories/cdp_repository.dart';
import 'package:indigo_insights/service_locator.dart';
import 'package:indigo_insights/theme/gradients.dart';
import 'package:indigo_insights/utils/async_builder.dart';
import 'package:indigo_insights/widgets/percentage_amount_chart.dart';

double calculateRedeemableAmount(Cdp cdp, double rmr, double adaPrice) {
  final ratio = cdp.collateralAmount / (adaPrice * cdp.mintedAmount);
  if (rmr <= ratio) return 0;
  return ((-cdp.collateralAmount / adaPrice) + rmr * cdp.mintedAmount) / (rmr - 1);
}

class RedeemableOverRmrsChart extends StatelessWidget {
  const RedeemableOverRmrsChart(this.indigoAsset, {super.key});

  final IndigoAsset indigoAsset;

  List<PercentageAmountData> _getRedeemableOverRmrsData(
    List<Cdp> cdps,
    double adaPrice,
    List<double> rmrs,
  ) {
    final redeemablePerCdp = cdps
        .map(
          (e) => rmrs.map(
            (rmr) => PercentageAmountData(
              rmr,
              calculateRedeemableAmount(e, rmr / 100, adaPrice),
            ),
          ),
        )
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
      ]).then((results) {
        final cdps = (results[0] as List<Cdp>)
            .where((e) => e.asset == indigoAsset.asset)
            .toList();
        final adaPrice = (results[1] as List<AssetPrice>)
            .firstWhere((e) => e.asset == indigoAsset.asset)
            .price;
        return (cdps: cdps, adaPrice: adaPrice);
      }),
      builder: (data) {
        return PercentageAmountChart(
          title: 'Redeemable over RMRs (${indigoAsset.rmr}%)',
          currency: indigoAsset.asset,
          labels: [indigoAsset.asset],
          mintedSupply: data.cdps.map((e) => e.mintedAmount).sum,
          data: [_getRedeemableOverRmrsData(data.cdps, data.adaPrice, rmrs)],
          colors: [getColorByAsset(indigoAsset.asset)],
          gradients: [getGradientByAsset(indigoAsset.asset)],
        );
      },
      errorBuilder: (error, retry) => Center(child: Text('Error: $error')),
    );
  }
}
