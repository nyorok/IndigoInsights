import 'package:flutter/material.dart';
import 'package:indigo_insights/theme/app_color_scheme.dart';
import 'package:indigo_insights/theme/app_text_styles.dart';
import 'package:indigo_insights/utils/formatters.dart';
import 'package:indigo_insights/widgets/animated_gradient_text.dart';

class AdaFarmingStabilityPoolCard extends StatelessWidget {
  const AdaFarmingStabilityPoolCard({
    super.key,
    required this.title,
    required this.collateralAsset,
    required this.strategyYield,
    required this.poolYield,
    required this.interestRate,
    required this.assetPrice,
    required this.debtMintingFee,
  });

  final String title;
  final String collateralAsset;
  final double strategyYield;
  final double poolYield;
  final double interestRate;
  final double assetPrice;
  final double debtMintingFee;

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

    valueText(String v, {Color? color, FontWeight? weight}) => Text(
      v,
      style: styles.monoSm.copyWith(
        color: color ?? colors.textPrimary,
        fontWeight: weight ?? FontWeight.w600,
      ),
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
                Text('$title SP ($collateral Collateral)', style: styles.cardTitle),
                AnimatedGradientText(
                  '${numberFormatter(strategyYield, 2)}%',
                  gradientColors: strategyYield > 0
                      ? [const Color(0xFFa500e1), const Color(0xFF3f83f8)]
                      : [const Color(0xFFa500e1), colors.error],
                  style: styles.kpiValue.copyWith(fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 12),
            informationRow(
              'Stability Pool APR',
              valueText('${numberFormatter(poolYield, 2)}%', color: colors.success),
            ),
            informationRow(
              'CDP Interest Rate',
              valueText('${numberFormatter(interestRate, 2)}%', color: colors.warning),
            ),
            Divider(color: colors.border, height: 16),
            informationRow('Collateral', valueText(collateral)),
            informationRow(
              'Price',
              valueText('${numberFormatter(assetPrice, 4)} $collateral'),
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
