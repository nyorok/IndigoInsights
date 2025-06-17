import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/utils/page_title.dart';
import 'package:indigo_insights/widgets/expandable_card.dart';
import 'package:indigo_insights/widgets/strategy_risk.dart';

class StrategiesOverview extends HookConsumerWidget {
  const StrategiesOverview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 960;

    return Card(
      margin: const EdgeInsets.all(8),
      child: ExpandableCard(
        collapsedHeight: 120.0,
        arrowPadding: 6,
        startExpanded: isDesktop,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageTitle(title: 'Strategy Insights Overview'),
              const SizedBox(height: 24),
              Text.rich(
                TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium,
                  children: [
                    const TextSpan(
                      text:
                          'Strategy Insights offers a deep dive into various yield-generating \nopportunities within the Indigo Protocol ecosystem.\n\n',
                    ),
                    const TextSpan(
                      text: 'Key Monitored Points\n',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(
                      text: ' • CDP Health: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(
                      text:
                          'Crucial indicators like redemption/maintenance ratios, liquidation thresholds, and minting fees.\n',
                    ),
                    const TextSpan(
                      text: ' • Yields and Other Metrics: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(
                      text:
                          'Real-time returns from Stability Pools and DEX Stable/Liquidity Pools, including trading fees, farming APRs and impermanent loss content.\n\n',
                    ),
                    const TextSpan(
                      text: 'Inside Each Strategy\n',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const TextSpan(
                      text: '  • Comprehensive Guides: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(
                      text:
                          'Detailed explanations of the mechanics and step-by-step application tutorials.\n',
                    ),
                    const TextSpan(
                      text: '  • Monitoring Advice: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(
                      text:
                          'Key aspects to watch for effective position management.\n\n',
                    ),
                    const TextSpan(
                      text: 'Strategy Risk Rating',
                      style: TextStyle(
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
                    const TextSpan(
                      text: ' Low Risk: Generally safer strategies.\n',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: StrategyRisk(riskLevel: RiskLevel.warning),
                    ),
                    const TextSpan(
                      text:
                          ' Moderate Risk: Higher leverage or market sensitivity.\n',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: StrategyRisk(riskLevel: RiskLevel.danger),
                    ),
                    const TextSpan(
                      text:
                          ' High Risk: Complex strategies with significant exposure.\n',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(
                      text:
                          'The number of icons (up to three) indicates relative risk within each category.\n\n',
                    ),
                    const TextSpan(
                      text: 'Risk Awareness',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const TextSpan(
                      text:
                          '\nWe provide a transparent discussion of inherent risks, using visual cues to highlight different risk levels:\n\n',
                    ),
                    const TextSpan(
                      text: '  •  Liquidation: ',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(
                      text:
                          'The potential for your collateral to be sold to cover your debt.\n',
                    ),
                    const TextSpan(
                      text: '  •  Redemption: ',
                      style: TextStyle(
                        color: Colors.yellowAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(
                      text:
                          'Exposure to having your CDP partially paid off by other users.\n',
                    ),
                    const TextSpan(
                      text: '  •  Impermanent Loss: ',
                      style: TextStyle(
                        color: Colors.yellowAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(
                      text:
                          'Potential value loss when providing liquidity in DEX pools.\n',
                    ),
                    const TextSpan(
                      text: '  •  Managing your Collateral Ratio (CR): ',
                      style: TextStyle(
                        color: Colors.greenAccent,
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
