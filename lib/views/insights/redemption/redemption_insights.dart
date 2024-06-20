import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/models/cdp.dart';
import 'package:indigo_insights/providers/asset_price_provider.dart';
import 'package:indigo_insights/providers/cdp_provider.dart';
import 'package:indigo_insights/providers/redemption_provider.dart';
import 'package:indigo_insights/utils/loader.dart';
import 'package:indigo_insights/views/insights/redemption/redeemable_over_rmrs_chart.dart';
import 'package:indigo_insights/views/insights/redemption/redemption_chart.dart';
import 'package:indigo_insights/views/insights/redemption/redemption_information.dart';

final cdpsAndPriceProvider = FutureProvider<
    ({
      List<Cdp> cdps,
      double adaPrice,
    })>((ref) async {
  final cdps = await ref
      .watch(cdpsProvider.future)
      .then((value) => value.where((e) => e.asset == 'iUSD').toList());

  final price = await ref
      .watch(assetPricesProvider.future)
      .then((value) => value.firstWhere((e) => e.asset == 'iUSD').price);

  return (cdps: cdps, adaPrice: price);
});

class RedemptionInsights extends StatefulHookConsumerWidget {
  const RedemptionInsights({super.key});

  @override
  ConsumerState<StatefulHookConsumerWidget> createState() =>
      _RedemptionInsightsState();
}

class _RedemptionInsightsState extends ConsumerState<RedemptionInsights>
    with TickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabLabels = List.from(["Redemption History", "Redeemable over RMRs"])
        .map((e) => Tab(
              text: e,
            ))
        .toList();

    return SingleChildScrollView(
      child: SelectionArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Align(
            alignment: Alignment.topLeft,
            child: Wrap(children: [
              Column(
                children: ref.watch(redemptionsProvider).when(
                      data: (redemptions) => redemptions
                          .groupListsBy((r) => r.asset)
                          .entries
                          .sortedBy((e) => e.key)
                          .map((entry) => informationCard(
                              RedemptionInformation(entry.key, entry.value),
                              context))
                          .toList(),
                      error: (error, stackTrace) => [Text(error.toString())],
                      loading: () => [const Loader()],
                    ),
              ),
              chartCard(
                  Column(
                    children: [
                      TabBar(
                        unselectedLabelColor: Colors.white,
                        labelColor: Colors.white,
                        tabs: tabLabels,
                        controller: _tabController,
                        indicatorSize: TabBarIndicatorSize.tab,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8, bottom: 8),
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              ref.watch(redemptionsProvider).when(
                                  data: (redemptions) => RedemptionChart(
                                      redemptions.groupListsBy((r) => r.asset)),
                                  error: (error, stackTrace) =>
                                      Text(error.toString()),
                                  loading: () => const Loader()),
                              ref.watch(cdpsAndPriceProvider).when(
                                  data: (data) => RedeemableOverRmrsChart(
                                      data.cdps, data.adaPrice),
                                  error: (error, stackTrace) =>
                                      Text(error.toString()),
                                  loading: () => const Loader()),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  context)
            ]),
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
        maxHeight: 189,
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
