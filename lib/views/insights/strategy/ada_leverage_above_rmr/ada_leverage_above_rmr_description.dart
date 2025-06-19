import 'package:flutter/material.dart';
import 'package:indigo_insights/theme/color_scheme.dart';
import 'package:indigo_insights/widgets/expandable_card.dart';

class AdaLeverageAboveRmrDescription extends StatelessWidget {
  const AdaLeverageAboveRmrDescription({super.key});

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
                  text: 'leveraging your ADA exposure ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text:
                      'through Indigo Collateralized Debt Positions (CDPs) to maximize your ADA holdings beyond initial collateral, based on the speculation that ADA will appreciate more than the iAsset.\n\n',
                ),
                const TextSpan(text: 'Here\'s how it works:\n\n'),
                const TextSpan(text: 'This strategy focuses on '),
                const TextSpan(
                  text: 'leveraging your ADA exposure ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text:
                      'through Indigo Collateralized Debt Positions (CDPs) to maximize your ADA holdings beyond initial collateral, based on the speculation that ADA will appreciate more than the iAsset.\n\n',
                ),
                const TextSpan(text: 'Here\'s how it works:\n\n'),
                const TextSpan(text: '1. ', style: TextStyle(letterSpacing: 2)),
                const TextSpan(
                  text: 'Open a CDP with ADA collateral:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text:
                      ' You deposit your ADA into an Indigo CDP to mint an iAsset (e.g., iUSD, iBTC, iETH). You should open your CDP with a Collateral Ratio (CR) at or higher than the RMR. Note that a higher CR results in lower leverage. The leverage can be calculated as: 1 + (100 / CR).\n',
                ),
                const TextSpan(text: '2.  '),
                const TextSpan(
                  text: 'Sell the minted iAsset for more ADA:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text:
                      ' You then sell the newly minted iAsset on a decentralized exchange (DEX) to acquire more ADA. This effectively increases your ADA exposure.\n\n',
                ),
                const TextSpan(text: 'The displayed '),
                const TextSpan(
                  text: 'leverage ratio ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text:
                      'indicates your total ADA exposure relative to your initial ADA collateral. This strategy comes with ',
                ),
                const TextSpan(
                  text: 'inherent risks ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryRed,
                  ),
                ),
                const TextSpan(
                  text:
                      'due to the nature of CDPs. Your Collateral Ratio (CR) is the primary metric to monitor, as it directly impacts the safety and profitability of your leveraged position. You should observe the RMR (Redemption Minimum Ratio) and Liquidation Ratio as crucial thresholds, noting that these values do not change frequently, but it is important to follow governance parameter proposals for any changes. Understanding and managing your CR in relation to these ratios is crucial to avoid potential redemptions or liquidations.\n\n',
                ),
                const TextSpan(text: 'Key Monitoring Points:\n\n'),
                const TextSpan(text: '• ', style: TextStyle(letterSpacing: 2)),
                const TextSpan(
                  text: 'Liquidation Risk',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
                const TextSpan(
                  text:
                      ': Your CDP can be liquidated if its Collateral Ratio (CR) falls below the Liquidation Ratio (110%). This means your collateral will be used to cover your minted debt, and you will incur losses. ',
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
                      ': If your CDP\'s CR falls below the RMR, it becomes eligible for redemption. This means other users can redeem your iAssets directly from your CDP by providing equivalent ADA. While this helps maintain the iAsset peg, it reduces your minted debt by redeeming equivalent ADA collateral until your CR reaches RMR again. ',
                ),
                const TextSpan(
                  text:
                      'Monitoring your CR relative to the RMR is vital to understand your exposure to redemptions.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: ' '),
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
