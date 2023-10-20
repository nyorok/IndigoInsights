import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/models/asset_price.dart';
import 'package:indigo_insights/models/cdp.dart';
import 'package:indigo_insights/models/indigo_asset.dart';
import 'package:indigo_insights/providers/asset_price_provider.dart';
import 'package:indigo_insights/providers/cdp_provider.dart';
import 'package:indigo_insights/utils/formatters.dart';
import 'package:indigo_insights/utils/loader.dart';
import 'package:indigo_insights/utils/page_title.dart';

final cdpsAndPriceProvider =
    FutureProvider.family<({List<Cdp> cdps, AssetPrice assetPrice}), String>(
        (ref, asset) async {
  final cdps = await ref
      .watch(cdpsProvider.future)
      .then((value) => value.where((e) => e.asset == asset).toList());

  final assetPrice = await ref
      .watch(assetPricesProvider.future)
      .then((value) => value.firstWhere((e) => e.asset == asset));

  return (cdps: cdps, assetPrice: assetPrice);
});

class CdpInformation extends HookConsumerWidget {
  const CdpInformation({super.key, required this.indigoAsset});

  final IndigoAsset indigoAsset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    calculatedAmount(double amount, BuildContext context,
            {String substring = "ADA"}) =>
        Row(
          children: [
            Text(
              numberFormatter(amount, 2),
            ),
            Text(
              " $substring",
              style: TextStyle(color: Theme.of(context).colorScheme.onTertiary),
            ),
          ],
        );

    informationRow(String title, Widget info) =>
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(title),
          info,
        ]);

    return ref.watch(cdpsAndPriceProvider(indigoAsset.asset)).when(
          data: (data) {
            final cdps = data.cdps;
            final assetPrice = data.assetPrice;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PageTitle(title: "${indigoAsset.asset} CDPs"),
                    Text(
                      numberFormatter(cdps.length, 0),
                      style: const TextStyle(fontSize: 18),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                informationRow(
                    'Collateral Ratio',
                    calculatedAmount(
                        100 *
                            cdps
                                .map((c) => (c.collateralAmount))
                                .reduce((value, element) => value + element) /
                            (cdps.map((c) => (c.mintedAmount)).reduce(
                                    (value, element) => value + element) *
                                assetPrice.price),
                        context,
                        substring: "%")),
                const Divider(),
                informationRow(
                    'Total Collateral',
                    calculatedAmount(
                        cdps
                            .map((c) => (c.collateralAmount))
                            .reduce((value, element) => value + element),
                        context)),
                const Divider(),
                informationRow(
                    'Total Minted',
                    calculatedAmount(
                        (cdps
                            .map((c) => (c.mintedAmount))
                            .reduce((value, element) => value + element)),
                        context,
                        substring: indigoAsset.asset)),
                const Divider(),
                informationRow(
                    'Biggest Collateral',
                    calculatedAmount(
                        cdps.map((c) => c.collateralAmount).reduce(
                            (value, element) =>
                                value > element ? value : element),
                        context)),
              ],
            );
          },
          error: (error, stackTrace) => Text(error.toString()),
          loading: () => const Loader(),
        );
  }
}
