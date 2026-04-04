import 'package:flutter/material.dart';
import 'package:indigo_insights/theme/app_color_scheme.dart';
import 'package:indigo_insights/theme/app_text_styles.dart';
import 'package:indigo_insights/views/insights/strategy/ada_double_leverage_above_mr/ada_double_leverage_above_mr_content.dart';
import 'package:indigo_insights/views/insights/strategy/ada_farming_stability_pool/ada_farming_stability_pool_content.dart';
import 'package:indigo_insights/views/insights/strategy/ada_farming_stable_pool/ada_farming_stable_pool_content.dart';
import 'package:indigo_insights/views/insights/strategy/ada_leverage_above_mr/ada_leverage_above_mr_content.dart';
import 'package:indigo_insights/views/insights/strategy/ada_leverage_above_rmr/ada_leverage_above_rmr_content.dart';
import 'package:indigo_insights/widgets/ii_tab_bar.dart';
import 'package:indigo_insights/widgets/ii_top_bar.dart';
import 'package:indigo_insights/widgets/strategy_risk.dart';

class StrategyInsights extends StatefulWidget {
  const StrategyInsights({super.key});

  @override
  State<StrategyInsights> createState() => _StrategyInsightsState();
}

class _StrategyInsightsState extends State<StrategyInsights>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _tabs = [
    (
      label: 'Stability Pool Farming Using ADA',
      risk: RiskLevel.safe,
      content: StabilityPoolFarmingStrategyContent(),
    ),
    (
      label: 'Stable Pool Farming Using ADA',
      risk: RiskLevel.safeSafe,
      content: StablePoolFarmingStrategyContent(),
    ),
    (
      label: 'ADA Leverage Above RMR',
      risk: RiskLevel.warningWarning,
      content: AdaLeverageAboveRmrContent(),
    ),
    (
      label: 'ADA Leverage Above MR',
      risk: RiskLevel.danger,
      content: AdaLeverageAboveMrContent(),
    ),
    (
      label: 'ADA Double Leverage Above MR',
      risk: RiskLevel.dangerDanger,
      content: AdaDoubleLeverageAboveMrContent(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 700;
    final colors = AppColorScheme.of(context);
    final styles = AppTextStyles.of(context);
    final selected = _tabs[_tabController.index];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const IITopBar(title: 'Strategy'),
        Expanded(
          child: SelectionArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: IITabBar(
                    controller: _tabController,
                    tabWidgets: _tabs.asMap().entries.map((e) {
                      final i = e.key;
                      final t = e.value;
                      if (isDesktop) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(t.label),
                            StrategyRisk(riskLevel: t.risk),
                          ],
                        );
                      }
                      return Text('S${i + 1}');
                    }).toList(),
                  ),
                ),
                if (!isDesktop)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            selected.label,
                            style: styles.cardTitle
                                .copyWith(color: colors.textPrimary),
                          ),
                        ),
                        const SizedBox(width: 8),
                        StrategyRisk(riskLevel: selected.risk),
                      ],
                    ),
                  ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: _tabs.map((t) => t.content).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
