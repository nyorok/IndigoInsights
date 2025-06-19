import 'package:flutter/material.dart';
import 'package:indigo_insights/widgets/expandable_card.dart';

class AdaFarmingStabilityPoolDescription extends StatelessWidget {
  const AdaFarmingStabilityPoolDescription({super.key});

  @override
  Widget build(BuildContext context) {
    return ExpandableCard(
      collapsedHeight: 55.0,
      arrowPadding: 6,
      color: Colors.transparent,
      child: Container(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text.rich(
            TextSpan(
              style: DefaultTextStyle.of(context).style,
              children: [
                const TextSpan(
                  text: 'Detailed Strategy\n\n',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const TextSpan(text: 'This strategy focuses on '),
                const TextSpan(
                  text: 'earning rewards from Indigo Stability Pools',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: ' while maintaining exposure to ADA.\n\n'),
                const TextSpan(text: 'Here\'s how it works:\n\n'),
                const TextSpan(text: '1. ', style: TextStyle(letterSpacing: 2)),
                const TextSpan(
                  text: 'Use your ADA to mint an iAsset:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text:
                      ' You can open a Collateralized Debt Position (CDP) in Indigo, using your ADA as collateral to mint an iAsset (iUSD, iBTC, iETH, etc).\n',
                ),
                const TextSpan(text: '2.  '),
                const TextSpan(
                  text: 'Stake the iAsset in the Stability Pool:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text:
                      ' You then stake this newly minted iAsset in an Indigo Stability Pool to earn additional yield.\n\n',
                ),
                const TextSpan(
                  text:
                      'The brilliant part from this strategy is that while your ADA is collateral, you ',
                ),
                const TextSpan(
                  text:
                      'continue to receive your native ADA staking rewards because you retain your staking key. ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text:
                      'So, you\'re earning yield from both your iAsset stake and your original ADA collateral. ',
                ),
                const TextSpan(
                  //plus the farming rewards minus the interest rate of your CDP,
                  text: 'Your net gain is the ',
                ),
                const TextSpan(
                  text: 'iAsset staking yield ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.greenAccent,
                  ),
                ),
                const TextSpan(text: 'minus the '),
                const TextSpan(
                  text: 'interest rate ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
                const TextSpan(text: 'of your CDP, '),
                const TextSpan(
                  text:
                      'all while your foundational ADA continues to generate its own rewards.\n\n',
                ),
                const TextSpan(text: 'Key Monitoring Points:\n\n'),
                const TextSpan(text: '• ', style: TextStyle(letterSpacing: 2)),
                const TextSpan(
                  text: 'Redemption Risk',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.yellowAccent,
                  ),
                ),
                const TextSpan(
                  text:
                      ': If your CDP\'s CR falls below the RMR, it becomes eligible for redemption. This means other users can redeem your iAssets directly from your CDP by providing equivalent ADA. While this helps maintain the iAsset peg, it reduces your minted debt by redeeming equivalent ADA collateral until your CR reaches RMR again. ',
                ),
                const TextSpan(
                  text:
                      'Monitoring your CR relative to the RMR is vital to understand your exposure to redemptions.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: '\n\n'),
                const TextSpan(text: '• ', style: TextStyle(letterSpacing: 2)),
                const TextSpan(
                  text: 'Managing your Collateral Ratio (CR)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.greenAccent,
                  ),
                ),
                const TextSpan(
                  text:
                      ': Regularly check the price of your collateral (ADA) and the iAsset price in ADA, and adjust your CDP by adding more collateral or repaying debt if needed. ',
                ),
                const TextSpan(
                  text:
                      'A higher CR provides a larger buffer against price fluctuations and reduces your risk of liquidation or redemption.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
