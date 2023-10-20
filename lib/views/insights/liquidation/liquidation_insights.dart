import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/providers/indigo_asset_provider.dart';
import 'package:indigo_insights/utils/loader.dart';
import 'package:indigo_insights/views/insights/liquidation/cumulative_liquidations_chart.dart';
import 'package:indigo_insights/views/insights/liquidation/liquidation_information.dart';

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
                Column(
                  children: [
                    ...ref.watch(indigoAssetsProvider).when(
                          data: (indigoAssets) => indigoAssets
                              .map((e) => informationCard(
                                  LiquidationInformation(
                                    indigoAsset: e,
                                  ),
                                  context))
                              .toList(),
                          loading: () => [const Loader()],
                          error: (error, stackTrace) =>
                              [Text(error.toString())],
                        )
                  ],
                ),
                chartCard(const CumulativeLiquidationsChart(), context)
              ],
            ),
          ),
        ),
      ),
    );
  }

  ConstrainedBox informationCard(Widget widget, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double width = screenWidth - 480 > 480 ? 480 : screenWidth;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: width),
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.all(8),
        child: Padding(padding: const EdgeInsets.all(16), child: widget),
      ),
    );
  }

  chartCard(Widget widget, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double width =
        screenWidth - 480 > 480 ? screenWidth - 480 : screenWidth;

    final screenHeight = MediaQuery.of(context).size.height;
    final double height = screenHeight - 68;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: width, maxHeight: height),
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.all(8),
        child: Padding(padding: const EdgeInsets.all(4), child: widget),
      ),
    );
  }
}
