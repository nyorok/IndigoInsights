import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/views/insights/minted_supply/minted_supply_history_chart.dart';
import 'package:indigo_insights/views/insights/minted_supply/minted_supply_information.dart';
import 'package:indigo_insights/widgets/indigo_asset_tabs.dart';
import 'package:indigo_insights/widgets/scrollable_information_cards.dart';

class MintedSupplyInsights extends StatefulHookConsumerWidget {
  const MintedSupplyInsights({super.key});

  @override
  ConsumerState<StatefulHookConsumerWidget> createState() =>
      _MintedSupplyInsightsState();
}

class _MintedSupplyInsightsState extends ConsumerState<MintedSupplyInsights> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SelectionArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Align(
              alignment: Alignment.topLeft,
              child: Wrap(
                children: [
                  ScrollableInformationCards(
                      (e) => MintedSupplyInformation(indigoAsset: e)),
                  IndigoAssetTabs((e) => MintedSupplyHistoryChart(
                        e,
                      ))
                ],
              )),
        ),
      ),
    );
  }
}
