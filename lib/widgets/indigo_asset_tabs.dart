import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/models/indigo_asset.dart';
import 'package:indigo_insights/providers/indigo_asset_provider.dart';
import 'package:indigo_insights/utils/loader.dart';

class IndigoAssetTabs extends StatefulHookConsumerWidget {
  final Widget Function(IndigoAsset) tabContentBuilder;

  const IndigoAssetTabs(this.tabContentBuilder, {super.key});

  @override
  ConsumerState<StatefulHookConsumerWidget> createState() =>
      _IndigoAssetTabsState();
}

class _IndigoAssetTabsState extends ConsumerState<IndigoAssetTabs>
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
    return ref.watch(indigoAssetsProvider).when(
          data: (indigoAssets) {
            _tabController = TabController(
              length: indigoAssets.length,
              vsync: this,
            );

            final tabLabels =
                indigoAssets.map((asset) => Tab(text: asset.asset)).toList();

            final tabContents =
                indigoAssets.map(widget.tabContentBuilder).toList();

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
          loading: () => const Loader(),
          error: (error, stackTrace) => Text(error.toString()),
        );
  }
}
