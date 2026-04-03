import 'package:flutter/material.dart';
import 'package:indigo_insights/models/indigo_asset.dart';
import 'package:indigo_insights/repositories/indigo_asset_repository.dart';
import 'package:indigo_insights/service_locator.dart';
import 'package:indigo_insights/utils/async_builder.dart';
import 'package:indigo_insights/utils/loader.dart';
import 'package:indigo_insights/views/insights/stability_pool/stability_pool_information.dart';
import 'package:indigo_insights/views/insights/stability_pool/stability_pool_solvency_chart.dart';

class StabilityPoolInsights extends StatefulWidget {
  const StabilityPoolInsights({super.key});

  @override
  State<StabilityPoolInsights> createState() => _StabilityPoolInsightsState();
}

class _StabilityPoolInsightsState extends State<StabilityPoolInsights>
    with TickerProviderStateMixin {
  TabController? _tabController;

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SelectionArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Align(
            alignment: Alignment.topLeft,
            child: AsyncBuilder(
              fetcher: () => sl<IndigoAssetRepository>().getAssets(),
              builder: (indigoAssets) {
                _tabController = TabController(
                  length: indigoAssets.length,
                  vsync: this,
                );
                return _stabilityPoolCards(context, indigoAssets: indigoAssets);
              },
              errorBuilder: (error, retry) => Text(error.toString()),
            ),
          ),
        ),
      ),
    );
  }

  Wrap _stabilityPoolCards(
    BuildContext context, {
    List<IndigoAsset>? indigoAssets,
  }) {
    final informationCards = indigoAssets
        ?.map(
          (e) => _informationCard(
            StabilityPoolInformation(indigoAsset: e),
            context,
          ),
        )
        .toList();

    final tabLabels = indigoAssets?.map((e) => Tab(text: e.asset)).toList();
    final tabContents = indigoAssets
        ?.map((e) => StabilityPoolSolvencyChart(indigoAsset: e))
        .toList();

    return Wrap(
      children: [
        Column(children: informationCards ?? [const Loader()]),
        _chartCard(
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
          context,
        ),
      ],
    );
  }

  ConstrainedBox _informationCard(Widget widget, BuildContext context) {
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

  Widget _chartCard(Widget widget, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double width = screenWidth - 480 > 480 ? screenWidth - 480 : screenWidth;
    final double height = MediaQuery.of(context).size.height - 68;

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
