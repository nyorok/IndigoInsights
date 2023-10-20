import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/models/indigo_asset.dart';
import 'package:indigo_insights/providers/indigo_asset_provider.dart';
import 'package:indigo_insights/utils/loader.dart';
import 'package:indigo_insights/views/insights/stability_pool/stability_pool_information.dart';
import 'package:indigo_insights/views/insights/stability_pool/stability_pool_solvency_chart.dart';

class StabilityPoolInsights extends StatefulHookConsumerWidget {
  const StabilityPoolInsights({super.key});

  @override
  ConsumerState<StatefulHookConsumerWidget> createState() =>
      _StabilityPoolInsightsState();
}

class _StabilityPoolInsightsState extends ConsumerState<StabilityPoolInsights>
    with TickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 1, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(indigoAssetsProvider).whenData((indigoAssets) => _tabController =
        TabController(length: indigoAssets.length, vsync: this));

    return SingleChildScrollView(
      child: SelectionArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Align(
            alignment: Alignment.topLeft,
            child: ref.watch(indigoAssetsProvider).when(
                  data: (indigoAssets) {
                    _tabController =
                        TabController(length: indigoAssets.length, vsync: this);

                    return stabilityPoolCards(context,
                        indigoAssets: indigoAssets);
                  },
                  loading: () => stabilityPoolCards(context),
                  error: (error, stackTrace) => Text(error.toString()),
                ),
          ),
        ),
      ),
    );
  }

  Wrap stabilityPoolCards(BuildContext context,
      {List<IndigoAsset>? indigoAssets}) {
    final informationCards = indigoAssets
        ?.map((e) => informationCard(
            StabilityPoolInformation(
              indigoAsset: e,
            ),
            context))
        .toList();

    final tabLabels = indigoAssets
        ?.map((e) => Tab(
              text: e.asset,
            ))
        .toList();

    final tabContents = indigoAssets
        ?.map((e) => StabilityPoolSolvencyChart(
              asset: e.asset,
            ))
        .toList();

    return Wrap(
      children: [
        Column(
          children: informationCards ?? [const Loader()],
        ),
        chartCard(
            Column(
              children: [
                TabBar(
                  unselectedLabelColor: Colors.white,
                  labelColor: Colors.white,
                  tabs: tabLabels ?? [const Loader()],
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8, bottom: 8),
                    child: TabBarView(
                      controller: _tabController,
                      children: tabContents ?? [const Loader()],
                    ),
                  ),
                ),
              ],
            ),
            context)
      ],
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
        clipBehavior: Clip.antiAlias,
        child: widget,
      ),
    );
  }
}
