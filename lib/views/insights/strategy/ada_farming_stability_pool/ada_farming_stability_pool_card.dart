import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/utils/formatters.dart';
import 'package:indigo_insights/utils/page_title.dart';
import 'package:indigo_insights/widgets/animated_gradient_text.dart';

class AdaFarmingStabilityPoolCard extends HookConsumerWidget {
  const AdaFarmingStabilityPoolCard({
    super.key,
    required this.title,
    required this.strategyYield,
    required this.poolYield,
    required this.interestRate,
    required this.redemptionMarginRatio,
    required this.maintenanceRatio,
    required this.liquidationRatio,
    required this.debtMintingFee,
  });

  final String title;
  final double strategyYield;
  final double poolYield;
  final double interestRate;
  final double redemptionMarginRatio;
  final double maintenanceRatio;
  final double liquidationRatio;
  final double debtMintingFee;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    informationRow(String title, Widget info) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(title), info],
    );

    calculatedAmount(double amount) => Text(
      "${numberFormatter(amount, 2)}%",
      style: TextStyle(color: Theme.of(context).colorScheme.onTertiary),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PageTitle(title: "$title SP"),
                AnimatedGradientText(
                  "${numberFormatter(strategyYield, 2)}%",
                  gradientColors: strategyYield > 0
                      ? [Color(0xFFa500e1), Color(0xFF3f83f8)]
                      : [
                          Color(0xFFa500e1),
                          Theme.of(context).colorScheme.onError,
                        ],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Quicksand",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            informationRow(
              'Stability Pool APR',
              Text(
                "${numberFormatter(poolYield, 2)}%",
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            informationRow(
              'CDP Interest Rate',
              Text(
                "${numberFormatter(interestRate, 2)}%",
                style: const TextStyle(
                  color: Colors.yellowAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(),
            informationRow(
              'Redemption Margin Ratio',
              calculatedAmount(redemptionMarginRatio),
            ),
            informationRow(
              'Maintenance Ratio',
              calculatedAmount(maintenanceRatio),
            ),
            informationRow(
              'Liquidation Ratio',
              calculatedAmount(liquidationRatio),
            ),
            informationRow('Minting Fee', calculatedAmount(debtMintingFee)),
          ],
        ),
      ),
    );
  }
}
