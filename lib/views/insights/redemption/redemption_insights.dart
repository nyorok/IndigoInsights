import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/providers/redemption_provider.dart';
import 'package:indigo_insights/utils/loader.dart';
import 'package:indigo_insights/views/insights/redemption/redemption_chart.dart';
import 'package:indigo_insights/views/insights/redemption/redemption_information.dart';

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
              children: ref.watch(redemptionsProvider).when(
                    data: (redemptions) {
                      final redemptionsByAsset =
                          redemptions.groupListsBy((r) => r.asset);

                      return [
                        Column(
                            children: redemptionsByAsset.entries
                                .sortedBy((e) => e.key)
                                .map((entry) => informationCard(
                                    RedemptionInformation(
                                        entry.key, entry.value),
                                    context))
                                .toList()),
                        chartCard(RedemptionChart(redemptionsByAsset), context)
                      ];
                    },
                    error: (error, stackTrace) => [Text(error.toString())],
                    loading: () => [const Loader()],
                  ),
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
      constraints: BoxConstraints(
        minWidth: 360,
        maxWidth: width,
        maxHeight: 170,
      ),
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
    final double height = screenHeight > screenWidth
        ? screenHeight - 260 > 430
            ? screenHeight - 260
            : 430
        : screenHeight - 68;

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
