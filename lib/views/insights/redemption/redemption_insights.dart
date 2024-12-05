import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/views/insights/redemption/redeemable_over_rmrs_chart.dart';
import 'package:indigo_insights/views/insights/redemption/redemption_information.dart';
import 'package:indigo_insights/widgets/indigo_asset_tabs.dart';
import 'package:indigo_insights/widgets/scrollable_information_cards.dart';

class RedemptionInsights extends HookConsumerWidget {
  const RedemptionInsights({super.key});

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
                    (e) => RedemptionInformation(e.asset)),
                IndigoAssetTabs((e) => RedeemableOverRmrsChart(e))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
