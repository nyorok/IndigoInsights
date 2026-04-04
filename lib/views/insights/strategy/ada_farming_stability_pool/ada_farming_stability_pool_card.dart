import 'package:flutter/material.dart';
import 'package:indigo_insights/theme/app_color_scheme.dart';
import 'package:indigo_insights/theme/app_text_styles.dart';
import 'package:indigo_insights/utils/formatters.dart';
import 'package:indigo_insights/widgets/animated_gradient_text.dart';

class AdaFarmingStabilityPoolCard extends StatelessWidget {
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$title SP', style: styles.cardTitle),
                AnimatedGradientText(
                  '${numberFormatter(strategyYield, 2)}%',
                  gradientColors: strategyYield > 0
                      ? [const Color(0xFFa500e1), const Color(0xFF3f83f8)]
                      : [
                          const Color(0xFFa500e1),
                          colors.error,
                        ],
                  style: styles.kpiValue.copyWith(fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 12),
            informationRow(
              'Stability Pool APR',
              Text(
                '${numberFormatter(poolYield, 2)}%',
                style: styles.monoSm.copyWith(
                  color: colors.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            informationRow(
              'CDP Interest Rate',
              Text(
                '${numberFormatter(interestRate, 2)}%',
                style: styles.monoSm.copyWith(
                  color: colors.warning,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Divider(color: colors.border, height: 16),
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
