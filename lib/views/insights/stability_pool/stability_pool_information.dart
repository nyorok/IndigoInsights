import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/providers/stability_pool_provider.dart';
import 'package:indigo_insights/utils/formatters.dart';
import 'package:indigo_insights/utils/loader.dart';

class StabilityPoolInformation extends HookConsumerWidget {
  const StabilityPoolInformation({super.key, required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    assetAmount(double amount, BuildContext context) => Row(
          children: [
            Text(
              numberFormatter(amount, 2),
            ),
            Text(
              " $asset",
              style: TextStyle(color: Theme.of(context).colorScheme.onTertiary),
            ),
          ],
        );

    informationRow(String title, Widget info) =>
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12),
          ),
          info,
        ]);

    return ref.watch(stabilityPoolProvider).when(
          data: (stabilityPools) {
            final assetStabilityPool =
                stabilityPools.firstWhere((sp) => sp.asset == asset);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Stability Pool $asset",
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 20),
                informationRow('Total Deposits',
                    assetAmount(assetStabilityPool.totalAmount, context)),
              ],
            );
          },
          error: (error, stackTrace) => Text(error.toString()),
          loading: () => const Loader(),
        );
  }
}
