import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/theme/color_scheme.dart';

class CustomTabs extends StatefulHookConsumerWidget {
  final List<({Tab tab, Widget tabContent})> tabs;

  const CustomTabs(this.tabs, {super.key});

  @override
  ConsumerState<StatefulHookConsumerWidget> createState() => _CustomTabsState();
}

class _CustomTabsState extends ConsumerState<CustomTabs>
    with TickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    _tabController = TabController(length: widget.tabs.length, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      clipBehavior: Clip.antiAlias,
      color: Colors.transparent,
      child: Column(
        children: [
          Container(
            color: secondaryBackground,
            child: TabBar(
              indicatorColor: Colors.white,
              unselectedLabelColor: Colors.white,
              labelColor: Colors.white,
              tabs: widget.tabs.map((tab) => tab.tab).toList(),
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              tabAlignment: TabAlignment.center,
              isScrollable: true,
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: widget.tabs
                  .map(
                    (tab) => SelectionArea(
                      child: Container(
                        color: Colors.transparent,
                        child: tab.tabContent,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    ).animate().fade(duration: 500.ms, curve: Curves.easeInOut);
  }
}
