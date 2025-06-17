import 'package:flutter/material.dart';
import 'package:indigo_insights/theme/color_scheme.dart';
import 'package:indigo_insights/widgets/expandable_card.dart';

class AdaDoubleLeverageAboveMrDescription extends StatelessWidget {
  const AdaDoubleLeverageAboveMrDescription({super.key});

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
                const TextSpan(
                  text:
                      'This strategy focuses on aggressively leveraging your ADA exposure twice through Indigo Collateralized Debt Positions (CDPs) to significantly maximize your ADA holdings, based on the speculation that ADA will appreciate more than the iAsset. In this strategy, your Collateral Ratio (CR) is maintained at a level where your CDP is always eligible for redemption, meaning you are constantly exposed to redemption risk.\n\n',
                ),
                const TextSpan(text: 'Here\'s how it works:\n\n'),
                const TextSpan(text: '1. ', style: TextStyle(letterSpacing: 2)),
                const TextSpan(
                  text: 'Open a CDP with ADA collateral:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text:
                      ' You deposit your ADA into an Indigo CDP and mint an iAsset (e.g., iUSD, iBTC, iETH), establishing a Collateral Ratio (CR) at or slightly below the RMR.\n',
                ),
                const TextSpan(text: '2.  '),
                const TextSpan(
                  text: 'Sell the minted iAsset for more ADA:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text:
                      ' You then sell the newly minted iAsset on a decentralized exchange (DEX) to acquire more ADA.\n',
                ),
                const TextSpan(text: '3.  '),
                const TextSpan(
                  text: 'Deposit the newly aquired ADA to your CDP:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text:
                      ' Deposit the ADA from the previous step back into your CDP to increase your total collateral.\n',
                ),
                const TextSpan(text: '4.  '),
                const TextSpan(
                  text: 'Mint more iAsset against the increased collateral:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text:
                      ' With more collateral in your CDP, you can now mint more iAsset.\n',
                ),
                const TextSpan(text: '5.  '),
                const TextSpan(
                  text: 'Sell the second minted iAsset for more ADA:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text:
                      ' Finally, you sell this second batch of minted iAsset for even more ADA, completing the double leverage loop and maximizing your exposure.\n\n',
                ),
                const TextSpan(
                  text:
                      'The displayed leverage ratio indicates your total ADA exposure relative to your initial collateral. This double-loop process comes with ',
                ),
                const TextSpan(
                  text: 'significantly amplified inherent risks ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryRed,
                  ),
                ),
                const TextSpan(
                  text:
                      'due to the nature of CDPs. Your Collateral Ratio (CR) is the primary metric to monitor. Understanding and managing your CR in relation to the RMR and Liquidation Ratio is crucial to avoid potential liquidations.\n\n',
                ),
                const TextSpan(text: 'Key Monitoring Points:\n\n'),
                const TextSpan(text: '• ', style: TextStyle(letterSpacing: 2)),
                const TextSpan(
                  text: 'Heightened Liquidation Risk',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
                const TextSpan(
                  text:
                      ': Your CDP can be liquidated if its CR falls below the Liquidation Ratio (110%). While the required collateral price drop to trigger liquidation is the same regardless of leverage, the magnitude of potential losses is significantly amplified with a larger position. ',
                ),
                const TextSpan(
                  text:
                      'Always maintain a healthy CR well above the liquidation threshold.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: '\n\n'),
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
                      ': In this strategy, your CDP\'s CR is intentionally maintained at a level at or slightly below the RMR, meaning it is always eligible for redemption. This means other users can redeem your iAssets directly from your CDP by providing equivalent ADA. While this helps maintain the iAsset peg, it reduces your minted debt by redeeming equivalent ADA collateral until your CR reaches RMR again. Understanding this constant exposure to redemptions is vital for this strategy.\n',
                ),
                const TextSpan(
                  text:
                      'However, in a falling market, if your CDP is redeemed, it can indirectly help you avoid liquidation by reducing your minted debt, which in turn increases your Collateral Ratio (CR) and overall CDP health.',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.greenAccent,
                  ),
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
                      ': Actively managing your CR is key to a successful leverage strategy. Regularly check the iAsset price in ADA, and adjust your CDP by adding more collateral or repaying debt if needed. ',
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
