import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/views/insights/cdp/cdp_information.dart';
import 'package:indigo_insights/views/insights/cdp/collateral_history_chart.dart';
import 'package:indigo_insights/widgets/indigo_asset_tabs.dart';
import 'package:indigo_insights/widgets/scrollable_information_cards.dart';

class CdpInsights extends HookConsumerWidget {
  const CdpInsights({super.key});

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
                    (e) => CdpInformation(indigoAsset: e)),
                IndigoAssetTabs((e) => CollateralHistoryChart(e))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
