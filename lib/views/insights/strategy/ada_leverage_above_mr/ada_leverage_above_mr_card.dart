import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/utils/formatters.dart';
import 'package:indigo_insights/utils/page_title.dart';
import 'package:indigo_insights/widgets/animated_gradient_text.dart';

class AdaLeverageAboveMrCard extends HookConsumerWidget {
  const AdaLeverageAboveMrCard({
    super.key,
    required this.asset,
    required this.interestRate,
    required this.redemptionMarginRatio,
    required this.maintenanceRatio,
    required this.liquidationRatio,
    required this.assetPrice,
    required this.debtMintingFee,
    required this.collateralRatio,
  });

  final String asset;
  final double interestRate;
  final double redemptionMarginRatio;
  final double maintenanceRatio;
  final double liquidationRatio;
  final double assetPrice;
  final double debtMintingFee;
  final double collateralRatio;

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

    // Calculate leverage
    final cr = collateralRatio / 100;
    final leverage = 1 + 1 / cr;

    // Calculate liquidation loss
    final liquidationLoss = -(1 - 1 / cr) * 100;

    // Calculate price drop until liquidation
    final priceDropToLiquidation =
        (1 - (liquidationRatio / collateralRatio)) * 100;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PageTitle(title: asset),
                Tooltip(
                  message:
                      "This is the maximum theoretical \nleverage achievable based on the \nMaintenance Ratio.",
                  child: AnimatedGradientText(
                    "${numberFormatter(leverage, 2)}x", // Display leverage based on MCR
                    gradientColors: [Colors.yellowAccent, Colors.greenAccent],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Quicksand",
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            informationRow(
              'Liquidation Price',
              Text(
                "-${numberFormatter(priceDropToLiquidation, 2)}%",
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            informationRow(
              'Liquidation Loss',
              Text(
                "${numberFormatter(liquidationLoss, 2)}%",
                style: const TextStyle(
                  color: Colors.orangeAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(),
            informationRow('Interest Rate', calculatedAmount(interestRate)),
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
