import 'package:flutter/material.dart';
import 'package:indigo_insights/models/indigo_asset.dart';
import 'package:indigo_insights/repositories/indigo_asset_repository.dart';
import 'package:indigo_insights/router.dart';
import 'package:indigo_insights/service_locator.dart';
import 'package:indigo_insights/utils/async_builder.dart';
import 'package:indigo_insights/utils/formatters.dart';
import 'package:indigo_insights/widgets/ii_tab_bar.dart';

/// iAsset tab bar that fetches assets from the repository and renders an
/// [IITabBar] with a [TabBarView] displaying the given [tabContentBuilder].
///
/// Pass [initialTabName] (e.g. `"iUSD"`) to pre-select a tab from a URL
/// query parameter. When the user switches tabs the widget calls [context.goTab]
/// to push the new tab name into the URL.
class IIAssetTabs extends StatefulWidget {
  const IIAssetTabs({
    super.key,
    required this.tabContentBuilder,
    this.initialTabName,
    @Deprecated('Use initialTabName') this.initialIndex = 0,
  });

  final Widget Function(IndigoAsset asset) tabContentBuilder;
  final String? initialTabName;
  // ignore: deprecated_member_use_from_same_package
  final int initialIndex;

  @override
  State<IIAssetTabs> createState() => _IIAssetTabsState();
}

class _IIAssetTabsState extends State<IIAssetTabs>
    with TickerProviderStateMixin {
  TabController? _controller;
  // Tracks the last known asset names to detect list changes.
  // ignore: unused_field
  List<String>? _lastAssetNames;

  int _resolveInitialIndex(List<IndigoAsset> assets) {
    final name = widget.initialTabName;
    if (name != null) {
      final idx = assets.indexWhere((a) => a.asset == name);
      if (idx >= 0) return idx;
    }
    // ignore: deprecated_member_use_from_same_package
    return widget.initialIndex.clamp(0, assets.length - 1);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AsyncBuilder<List<IndigoAsset>>(
      fetcher: () => sl<IndigoAssetRepository>().getAssets().then(
            (list) => sortedByAsset(list, (a) => a.asset),
          ),
      builder: (assets) {
        _lastAssetNames = assets.map((a) => a.asset).toList();
        if (_controller == null || _controller!.length != assets.length) {
          _controller?.dispose();
          _controller = TabController(
            length: assets.length,
            vsync: this,
            initialIndex: _resolveInitialIndex(assets),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: IITabBar(
                tabs: assets.map((a) => a.asset).toList(),
                controller: _controller,
                onTap: (i) => context.goTab(assets[i].asset),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _controller,
                children: assets
                    .map((a) => widget.tabContentBuilder(a))
                    .toList(),
              ),
            ),
          ],
        );
      },
      errorBuilder: (error, retry) => Center(
        child: Text(error.toString()),
      ),
    );
  }
}
