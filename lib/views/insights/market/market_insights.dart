import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/providers/indigo_asset_provider.dart';
import 'package:indigo_insights/utils/loader.dart';
import 'package:indigo_insights/views/insights/market/indigo_asset_market_distribution_pie_chart.dart';

class MarketInsights extends HookConsumerWidget {
  const MarketInsights({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: SelectionArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Align(
            alignment: Alignment.topLeft,
            child: Wrap(
              alignment: WrapAlignment.end,
              children: [
                ...ref.watch(indigoAssetsProvider).when(
                    data: (indigoAssets) => indigoAssets
                        .map((e) => chartCard(
                            IndigoAssetMarketDistributionPieChart(
                              indigoAsset: e,
                            ),
                            context))
                        .toList(),
                    error: (error, stackTrace) => [Text(error.toString())],
                    loading: () => [const Loader()])
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget informationCard(Widget widget, BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.all(8),
        child: Padding(padding: const EdgeInsets.all(16), child: widget),
      ),
    );
  }

  Widget chartCard(Widget widget, BuildContext context) {
    return cardContainer(
        Card(
          elevation: 2,
          margin: const EdgeInsets.all(8),
          child: Padding(padding: const EdgeInsets.all(4), child: widget),
        ),
        context);
  }

  Widget cardContainer(Widget widget, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double width = screenWidth / 2 > 480 ? screenWidth / 2 : 480;

    final screenHeight = MediaQuery.of(context).size.height;
    final double height =
        screenHeight > screenWidth ? width + 40 : screenHeight - 68;

    return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: width, maxHeight: height),
        child: widget);
  }
}
