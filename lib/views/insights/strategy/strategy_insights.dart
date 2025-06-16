import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/views/insights/strategy/ada_double_leverage_above_mr/ada_double_leverage_above_mr_content.dart';
import 'package:indigo_insights/views/insights/strategy/ada_farming_stability_pool/ada_farming_stability_pool_content.dart';
import 'package:indigo_insights/views/insights/strategy/ada_farming_stable_pool/ada_farming_stable_pool_content.dart';
import 'package:indigo_insights/views/insights/strategy/ada_leverage_above_mr/ada_leverage_above_mr_content.dart';
import 'package:indigo_insights/views/insights/strategy/ada_leverage_above_rmr/ada_leverage_above_rmr_content.dart';
import 'package:indigo_insights/views/insights/strategy/strategies_overview.dart';
import 'package:indigo_insights/widgets/custom_tabs.dart';
import 'package:indigo_insights/widgets/strategy_risk.dart';

class StrategyInsights extends HookConsumerWidget {
  const StrategyInsights({super.key});

  Widget informationRowWithTooltip(String title, Widget info, String tooltip) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [info],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: SelectionArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Wrap(
            children: [
              const StrategiesOverview(),
              CustomTabs([
                (
                  tab: Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Stability Pool Farming Using ADA"),
                        const StrategyRisk(riskLevel: RiskLevel.safe),
                      ],
                    ),
                  ),
                  tabContent: StabilityPoolFarmingStrategyContent(),
                ),
                (
                  tab: Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Stable Pool Farming Using ADA"),
                        const StrategyRisk(riskLevel: RiskLevel.safeSafe),
                      ],
                    ),
                  ),
                  tabContent: StablePoolFarmingStrategyContent(),
                ),
                (
                  tab: Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("ADA Leverage Above RMR"),
                        const StrategyRisk(riskLevel: RiskLevel.warningWarning),
                      ],
                    ),
                  ),
                  tabContent: AdaLeverageAboveRmrContent(),
                ),
                (
                  tab: Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("ADA Leverage Above MR"),
                        const StrategyRisk(riskLevel: RiskLevel.danger),
                      ],
                    ),
                  ),
                  tabContent: AdaLeverageAboveMrContent(),
                ),
                (
                  tab: Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("ADA Double Leverage Above MR"),
                        const StrategyRisk(riskLevel: RiskLevel.dangerDanger),
                      ],
                    ),
                  ),
                  tabContent: AdaDoubleLeverageAboveMrContent(),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
