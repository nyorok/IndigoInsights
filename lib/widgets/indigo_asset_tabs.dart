import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:indigo_insights/models/indigo_asset.dart';
import 'package:indigo_insights/repositories/indigo_asset_repository.dart';
import 'package:indigo_insights/service_locator.dart';
import 'package:indigo_insights/utils/async_builder.dart';

class IndigoAssetTabs extends StatefulWidget {
  final Widget Function(IndigoAsset) tabContentBuilder;

  const IndigoAssetTabs(this.tabContentBuilder, {super.key});

  @override
  State<IndigoAssetTabs> createState() => _IndigoAssetTabsState();
}

class _IndigoAssetTabsState extends State<IndigoAssetTabs>
    with TickerProviderStateMixin {
  TabController? _tabController;

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AsyncBuilder(
      fetcher: () => sl<IndigoAssetRepository>().getAssets(),
      builder: (indigoAssets) {
        _tabController = TabController(length: indigoAssets.length, vsync: this);

        final tabLabels = indigoAssets.map((asset) => Tab(text: asset.asset)).toList();
        final tabContents = indigoAssets.map(widget.tabContentBuilder).toList();

        final screenWidth = MediaQuery.of(context).size.width;
        final double width = screenWidth - 480 > 480 ? screenWidth - 480 : screenWidth;
        final double height = MediaQuery.of(context).size.height - 68;

        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: width, maxHeight: height),
          child: Card(
            elevation: 2,
            margin: const EdgeInsets.all(8),
            clipBehavior: Clip.antiAlias,
            child: Column(
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
                      children: tabContents,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      errorBuilder: (error, retry) => Text(error.toString()),
    ).animate().fade(duration: 500.ms, curve: Curves.easeInOut);
  }
}
