import 'package:flutter/material.dart';
import 'package:indigo_insights/service_locator.dart';
import 'package:indigo_insights/theme/color_scheme.dart';
import 'package:indigo_insights/theme/gradients.dart';
import 'package:indigo_insights/utils/page_title.dart';
import 'package:indigo_insights/views/insights/indy_staking/indy_staking_insights.dart';
import 'package:indigo_insights/views/insights/liquidation/liquidation_insights.dart';
import 'package:indigo_insights/views/insights/redemption/redemption_insights.dart';
import 'package:indigo_insights/views/insights/stability_pool/stability_pool_insights.dart';
import 'package:indigo_insights/views/insights/stability_pool_account/stability_pool_account_insights.dart';
import 'package:indigo_insights/views/insights/strategy/strategy_insights.dart';

import 'sidebar.dart';

void main() async {
  setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedMenuItem = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Indigo Insights',
      theme: _getTheme(context),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: colorScheme.surfaceContainerLow,
          title: const Row(
            children: [
              PageTitle(title: 'Indigo Insights', fontSize: 22),
              SizedBox(width: 3),
            ],
          ),
          leading: Builder(
            builder: (innerContext) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(innerContext).openDrawer(),
            ),
          ),
        ),
        drawer: Sidebar(
          onMenuItemPressed: (value) => setState(() => _selectedMenuItem = value),
          selectedMenu: _selectedMenuItem,
        ),
        body: Row(
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(gradient: indigoDarkGradient),
                child: switch (SidebarMenu.values[_selectedMenuItem]) {
                  SidebarMenu.strategy => const StrategyInsights(),
                  SidebarMenu.liquidation => const LiquidationInsights(),
                  SidebarMenu.redemption => const RedemptionInsights(),
                  SidebarMenu.indyStaking => const IndyStakingInsights(),
                  SidebarMenu.stabilityPool => const StabilityPoolInsights(),
                  SidebarMenu.stabilityPoolAccount =>
                    const StabilityPoolAccountInsights(),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  ThemeData _getTheme(BuildContext context) {
    return ThemeData(
      fontFamily: 'Quicksand',
      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontSize: 12.8, fontFamily: 'Quicksand'),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        selectionColor: Colors.blueGrey,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.hovered)) {
              return Theme.of(context).colorScheme.primary.withValues(alpha: .08);
            }
            return null;
          },
        ),
      ),
      colorScheme: colorScheme,
      useMaterial3: true,
    );
  }
}
