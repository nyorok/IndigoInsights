import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/models/indigo_asset.dart';
import 'package:indigo_insights/models/stability_pool.dart';
import 'package:indigo_insights/providers/asset_status_provider.dart';
import 'package:indigo_insights/providers/stability_pool_provider.dart';
import 'package:indigo_insights/utils/formatters.dart';
import 'package:indigo_insights/utils/loader.dart';
import 'package:indigo_insights/utils/page_title.dart';

final stabilityPoolInformationProvider =
    FutureProvider.family<
      ({StabilityPool stabilityPool, double totalSupply}),
      IndigoAsset
    >((ref, indigoAsset) async {
      final stabilityPool = await ref
          .watch(stabilityPoolProvider.future)
          .then(
            (value) => value.firstWhere((e) => e.asset == indigoAsset.asset),
          );

      final totalSupply = await ref
          .watch(assetStatusProvider.future)
          .then(
            (value) => value
                .firstWhere((e) => e.asset == indigoAsset.asset)
                .totalSupply,
          );

      return (stabilityPool: stabilityPool, totalSupply: totalSupply);
    });

class StabilityPoolInformation extends HookConsumerWidget {
  const StabilityPoolInformation({super.key, required this.indigoAsset});

  final IndigoAsset indigoAsset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    assetAmount(double amount, String currency, BuildContext context) => Row(
      children: [
        Text(numberFormatter(amount, 2)),
        Text(
          " $currency",
          style: TextStyle(color: Theme.of(context).colorScheme.onTertiary),
        ),
      ],
    );

    informationRow(String title, Widget info) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(title), info],
    ).animate().scaleY(duration: 300.ms, curve: Curves.easeInOut);

    return ref
        .watch(stabilityPoolInformationProvider(indigoAsset))
        .when(
          data: (data) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageTitle(
                  title: "${indigoAsset.asset} Stability Pool",
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
                    "%",
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
