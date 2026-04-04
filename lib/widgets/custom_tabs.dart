import 'package:flutter/material.dart';
import 'package:indigo_insights/theme/app_color_scheme.dart';
import 'package:indigo_insights/widgets/ii_card.dart';
import 'package:indigo_insights/widgets/ii_tab_bar.dart';

/// A [Card] + [TabBar] + [TabBarView] combo using the [IITabBar] design.
///
/// Accepts a list of `(Tab tab, Widget tabContent)` records — same API as
/// the old `CustomTabs` so call-sites can migrate without changes except
/// the import path.
class CustomTabs extends StatefulWidget {
  final List<({Tab tab, Widget tabContent})> tabs;

  const CustomTabs(this.tabs, {super.key});

  @override
  State<CustomTabs> createState() => _CustomTabsState();
}

class _CustomTabsState extends State<CustomTabs> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);

    return IICard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: IITabBar(
              tabWidgets: widget.tabs
                  .map((t) => t.tab.child ?? Text(t.tab.text ?? ''))
                  .toList(),
              controller: _tabController,
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: widget.tabs
                  .map(
                    (tab) => SelectionArea(
                      child: ColoredBox(
                        color: colors.surface,
                        child: tab.tabContent,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
