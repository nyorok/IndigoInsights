import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/providers/liquidation_provider.dart';
import 'package:indigo_insights/utils/formatters.dart';
import 'package:indigo_insights/utils/loader.dart';

class LiquidationInformation extends HookConsumerWidget {
  const LiquidationInformation({super.key});
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
          Text(
            title,
            style: const TextStyle(fontSize: 12),
          ),
          info,
        ]);

    return ref.watch(liquidationProvider).when(
          data: (liquidations) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Liquidations",
                    style: TextStyle(fontSize: 14),
                  ),
                  Text(
                    numberFormatter(liquidations.length, 0),
                    style: const TextStyle(fontSize: 18),
                  )
                ],
              ),
              const SizedBox(height: 20),
              informationRow(
                  'Total Liquidated',
                  adaAmount(liquidations.map((c) => c.collateralAbsorbed).sum,
                      context)),
              informationRow(
                  'Biggest iUSD Liquidated',
                  adaAmount(
                      liquidations
                          .where((c) => c.asset == "iUSD")
                          .map((c) => c.collateralAbsorbed)
                          .reduce((value, element) =>
                              value > element ? value : element),
                      context)),
              informationRow(
                  'Biggest iBTC Liquidated',
                  adaAmount(
                      liquidations
                          .where((c) => c.asset == "iBTC")
                          .map((c) => c.collateralAbsorbed)
                          .reduce((value, element) =>
                              value > element ? value : element),
                      context)),
              informationRow(
                  'Biggest iETH Liquidated',
                  adaAmount(
                      liquidations
                          .where((c) => c.asset == "iETH")
                          .map((c) => c.collateralAbsorbed)
                          .reduce((value, element) =>
                              value > element ? value : element),
                      context))
            ],
          ),
          error: (error, stackTrace) => Text(error.toString()),
          loading: () => const Loader(),
        );
  }
}
