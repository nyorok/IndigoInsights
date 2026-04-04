import 'package:flutter/material.dart';
import 'package:indigo_insights/theme/app_color_scheme.dart';
import 'package:indigo_insights/theme/app_text_styles.dart';
import 'package:indigo_insights/utils/formatters.dart';
import 'package:indigo_insights/widgets/animated_gradient_text.dart';

class AdaDoubleLeverageAboveMrCard extends StatelessWidget {
  const AdaDoubleLeverageAboveMrCard({
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
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final styles = AppTextStyles.of(context);

    informationRow(String label, Widget info) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: styles.bodySm.copyWith(color: colors.textSecondary)),
          info,
        ],
      ),
    );

    calculatedAmount(double amount) => Text(
      '${numberFormatter(amount, 2)}%',
      style: styles.monoSm.copyWith(color: colors.textPrimary),
    );

    final cr = collateralRatio / 100;
    final doubleLeverage = 1 + (1 + 1 / cr) / cr;
    final liquidationLoss = -(1 - (1 / cr) / cr) * 100;
    final priceDropToLiquidation = (1 - (liquidationRatio / collateralRatio)) * 100;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(asset, style: styles.cardTitle),
                Tooltip(
                  message:
                      'This is the maximum theoretical double\nleverage achievable based on the\nMaintenance Ratio.',
                  child: AnimatedGradientText(
                    '${numberFormatter(doubleLeverage, 2)}x',
                    gradientColors: [colors.success, colors.error],
                    style: styles.kpiValue.copyWith(fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            informationRow(
              'Liquidation Price Drop',
              Text(
                '-${numberFormatter(priceDropToLiquidation, 2)}%',
                style: styles.monoSm.copyWith(color: colors.error, fontWeight: FontWeight.bold),
              ),
            ),
            informationRow(
              'Liquidation Loss',
              Text(
                '${numberFormatter(liquidationLoss, 2)}%',
                style: styles.monoSm.copyWith(color: colors.error, fontWeight: FontWeight.bold),
              ),
            ),
            Divider(color: colors.border, height: 16),
            informationRow('Interest Rate', calculatedAmount(interestRate)),
            informationRow('Redemption Margin Ratio', calculatedAmount(redemptionMarginRatio)),
            informationRow('Maintenance Ratio', calculatedAmount(maintenanceRatio)),
            informationRow('Liquidation Ratio', calculatedAmount(liquidationRatio)),
            informationRow('Minting Fee', calculatedAmount(debtMintingFee)),
          ],
        ),
      ),
    );
  }
}
