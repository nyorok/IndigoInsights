import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/views/insights/liquidation/cumulative_liquidations_chart.dart';
import 'package:indigo_insights/views/insights/liquidation/liquidation_information.dart';
import 'package:indigo_insights/widgets/indigo_asset_tabs.dart';
import 'package:indigo_insights/widgets/scrollable_information_cards.dart';

class LiquidationInsights extends HookConsumerWidget {
  const LiquidationInsights({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: SelectionArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Align(
            alignment: Alignment.topLeft,
            child: Wrap(
              children: [
                ScrollableInformationCards(
                    (e) => LiquidationInformation(indigoAsset: e)),
                IndigoAssetTabs((e) => CumulativeLiquidationsChart(e))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
