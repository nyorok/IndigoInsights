import 'package:flutter/material.dart';
import 'package:indigo_insights/theme/app_color_scheme.dart';
import 'package:indigo_insights/theme/app_text_styles.dart';
import 'package:indigo_insights/widgets/expandable_card.dart';
import 'package:indigo_insights/widgets/ii_card.dart';
import 'package:indigo_insights/widgets/strategy_risk.dart';

class StrategiesOverview extends StatelessWidget {
  const StrategiesOverview({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final styles = AppTextStyles.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 960;

    return IICard(
      padding: EdgeInsets.zero,
      child: ExpandableCard(
        collapsedHeight: 120.0,
        arrowPadding: 6,
        startExpanded: isDesktop,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Strategy Insights Overview', style: styles.cardTitle),
              const SizedBox(height: 24),
              Text.rich(
                TextSpan(
                  style: styles.bodyMd,
                  children: [
                    const TextSpan(
                      text:
                          'Strategy Insights offers a deep dive into various yield-generating \nopportunities within the Indigo Protocol ecosystem.\n\n',
                    ),
                    TextSpan(
                      text: 'Key Monitored Points\n',
                      style: styles.bodyMd.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    TextSpan(
                      text: ' • CDP Health: ',
                      style: styles.bodyMd.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(
                      text:
                          'Crucial indicators like redemption/maintenance ratios, liquidation thresholds, and minting fees.\n',
                    ),
                    TextSpan(
                      text: ' • Yields and Other Metrics: ',
                      style: styles.bodyMd.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(
                      text:
                          'Real-time returns from Stability Pools and DEX Stable/Liquidity Pools, including trading fees, farming APRs and impermanent loss content.\n\n',
                    ),
                    TextSpan(
                      text: 'Inside Each Strategy\n',
                      style: styles.bodyMd.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    TextSpan(
                      text: '  • Comprehensive Guides: ',
                      style: styles.bodyMd.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(
                      text:
                          'Detailed explanations of the mechanics and step-by-step application tutorials.\n',
                    ),
                    TextSpan(
                      text: '  • Monitoring Advice: ',
                      style: styles.bodyMd.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(
                      text:
                          'Key aspects to watch for effective position management.\n\n',
                    ),
                    TextSpan(
                      text: 'Strategy Risk Rating',
                      style: styles.bodyMd.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const TextSpan(
                      text:
                          '\nEach strategy is assigned a risk rating for a quick visual guide. This considers factors like complexity, liquidation potential, and market volatility.\n',
                    ),
                    const WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: StrategyRisk(riskLevel: RiskLevel.safe),
                    ),
                    TextSpan(
                      text: ' Low Risk: Generally safer strategies.\n',
                      style: styles.bodyMd.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: StrategyRisk(riskLevel: RiskLevel.warning),
                    ),
                    TextSpan(
                      text:
                          ' Moderate Risk: Higher leverage or market sensitivity.\n',
                      style: styles.bodyMd.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: StrategyRisk(riskLevel: RiskLevel.danger),
                    ),
                    TextSpan(
                      text:
                          ' High Risk: Complex strategies with significant exposure.\n',
                      style: styles.bodyMd.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(
                      text:
                          'The number of icons (up to three) indicates relative risk within each category.\n\n',
                    ),
                    TextSpan(
                      text: 'Risk Awareness',
                      style: styles.bodyMd.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const TextSpan(
                      text:
                          '\nWe provide a transparent discussion of inherent risks, using visual cues to highlight different risk levels:\n\n',
                    ),
                    TextSpan(
                      text: '  •  Liquidation: ',
                      style: styles.bodyMd.copyWith(
                        color: colors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(
                      text:
                          'The potential for your collateral to be sold to cover your debt.\n',
                    ),
                    TextSpan(
                      text: '  •  Redemption: ',
                      style: styles.bodyMd.copyWith(
                        color: colors.warning,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(
                      text:
                          'Exposure to having your CDP partially paid off by other users.\n',
                    ),
                    TextSpan(
                      text: '  •  Impermanent Loss: ',
                      style: styles.bodyMd.copyWith(
                        color: colors.warning,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(
                      text:
                          'Potential value loss when providing liquidity in DEX pools.\n',
                    ),
                    TextSpan(
                      text: '  •  Managing your Collateral Ratio (CR): ',
                      style: styles.bodyMd.copyWith(
                        color: colors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(
                      text:
                          'Managing the ratio of your collateral in relation to your debt, which affects your risk exposure and potential returns.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
