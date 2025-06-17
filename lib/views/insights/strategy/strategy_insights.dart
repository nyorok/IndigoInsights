import 'dart:math';

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDesktop = screenWidth > 960;

    return SingleChildScrollView(
      child: SelectionArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left side - StrategiesOverview
                    SizedBox(width: 480, child: const StrategiesOverview()),
                    const SizedBox(width: 16),
                    // Right side - CustomTabs
                    Expanded(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth:
                              screenWidth -
                              480 -
                              32, // Account for overview width + spacing + padding
                          maxHeight: max(0.0, screenHeight - 65),
                        ),
                        child: _buildCustomTabs(),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    const StrategiesOverview(),
                    const SizedBox(height: 16),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: screenWidth,
                        maxHeight: max(0.0, screenHeight - 65),
                      ),
                      child: _buildCustomTabs(),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildCustomTabs() {
    return CustomTabs([
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
    ]);
  }
}
