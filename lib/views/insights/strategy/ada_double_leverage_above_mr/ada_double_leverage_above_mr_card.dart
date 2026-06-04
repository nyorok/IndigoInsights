import 'package:flutter/material.dart';
import 'package:indigo_insights/theme/app_color_scheme.dart';
import 'package:indigo_insights/theme/app_text_styles.dart';
import 'package:indigo_insights/utils/formatters.dart';
import 'package:indigo_insights/widgets/animated_gradient_text.dart';

class AdaDoubleLeverageAboveMrCard extends StatelessWidget {
  const AdaDoubleLeverageAboveMrCard({
    super.key,
    required this.asset,
    required this.collateralAsset,
    required this.interestRate,
    required this.assetPrice,
    required this.debtMintingFee,
    required this.collateralRatio,
  });

  final String asset;
  final String collateralAsset;
  final double interestRate;
  final double assetPrice;
  final double debtMintingFee;
  final double collateralRatio;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final styles = AppTextStyles.of(context);
    final collateral = collateralLabel(collateralAsset);

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

    valueText(String v, {Color? color}) => Text(
      v,
      style: styles.monoSm.copyWith(
        color: color ?? colors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    );

    final cr = collateralRatio / 100;
    final doubleLeverage = 1 + (1 + 1 / cr) / cr;
    final liquidationLoss = -(1 - (1 / cr) / cr) * 100;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$asset ($collateral Collateral)', style: styles.cardTitle),
                Tooltip(
                  message:
                      'Maximum theoretical double\nleverage based on the Maintenance Ratio.',
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
              'Liquidation Loss',
              valueText('${numberFormatter(liquidationLoss, 2)}%', color: colors.error),
            ),
            Divider(color: colors.border, height: 16),
            informationRow('Collateral', valueText(collateral)),
            informationRow(
              'Price',
              valueText('${numberFormatter(assetPrice, 4)} $collateral'),
            ),
            informationRow(
              'Interest Rate',
              valueText('${numberFormatter(interestRate, 2)}%'),
            ),
            informationRow(
              'Minting Fee',
              valueText('${numberFormatter(debtMintingFee, 2)}%'),
            ),
          ],
        ),
      ),
    );
  }
}
