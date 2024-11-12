import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/providers/indigo_asset_provider.dart';
import 'package:indigo_insights/theme/color_scheme.dart';
import 'package:indigo_insights/views/insights/cdp/cdp_insights.dart';
import 'package:indigo_insights/views/insights/indy_staking/indy_staking_insights.dart';
import 'package:indigo_insights/views/insights/liquidation/liquidation_insights.dart';
import 'package:indigo_insights/views/insights/market/market_insights.dart';
import 'package:indigo_insights/views/insights/minted_supply/minted_supply_insights.dart';
import 'package:indigo_insights/views/insights/redemption/redemption_insights.dart';
import 'package:indigo_insights/views/insights/stability_pool/stability_pool_insights.dart';
import 'package:indigo_insights/views/insights/stability_pool_account/stability_pool_account_insights.dart';
import 'package:indigo_insights/views/insights/staking_rewards/staking_rewards_insights.dart';
import 'package:indigo_insights/views/tables/cdps_table.dart';
import 'package:indigo_insights/views/tables/liquidations_table.dart';

import 'sidebar.dart';
import 'utils/loader.dart';

void main() async {
  runApp(const ProviderScope(child: MyApp()));
}

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class MyApp extends HookConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMenuItem = useState(0);

    return MaterialApp(
      title: 'Indigo Insights',
      theme: getTheme(context),
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: colorScheme.surfaceContainerLow,
          title: Row(
            children: [
              const Text('Indigo Insights'),
              const SizedBox(width: 3),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Image.asset(
                  'assets/pwg-logo-50.png',
                  width: 25,
                  height: 25,
                ),
              ),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () async {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
        ),
        drawer: ref.watch(indigoAssetsProvider).when(
              loading: () => const Loader(),
              error: (err, stack) => Text('Error: $err'),
              data: (assets) => Sidebar(
                  onMenuItemPressed: (value) => selectedMenuItem.value = value,
                  selectedMenu: selectedMenuItem.value,
                  assets: assets),
            ),
        body: Row(
          children: [
            Expanded(
              child: switch (SidebarMenu.values[selectedMenuItem.value]) {
                SidebarMenu.liquidation => const LiquidationInsights(),
                SidebarMenu.cdps => const CdpInsights(),
                SidebarMenu.mintedSupply => const MintedSupplyInsights(),
                SidebarMenu.indyStaking => const IndyStakingInsights(),
                SidebarMenu.stakingRewards => const StakingRewardsInsights(),
                SidebarMenu.redemption => const RedemptionInsights(),
                SidebarMenu.stabilityPool => const StabilityPoolInsights(),
                SidebarMenu.stabilityPoolAccount =>
                  const StabilityPoolAccountInsights(),
                SidebarMenu.market => const MarketInsights(),
                SidebarMenu.liquidationTable =>
                  centeredPageContainer(const LiquidationsTable()),
                SidebarMenu.cdpsTable =>
                  centeredPageContainer(const CdpsTable())
              },
            ),
          ],
        ),
      ),
    );
  }

  ThemeData getTheme(BuildContext context) {
    return ThemeData(
      fontFamily: 'Quicksand',
      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontSize: 12.8, fontFamily: 'Quicksand'),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        selectionColor: Colors.blueGrey,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      dataTableTheme: DataTableThemeData(headingRowColor:
          WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        if (states.contains(WidgetState.hovered)) {
          return Theme.of(context).colorScheme.primary.withOpacity(0.08);
        }
        return null;
      })),
      colorScheme: colorScheme,
      useMaterial3: true,
    );
  }

  Center centeredPageContainer(Widget widget) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 968, maxWidth: 968),
        child: Card(
          elevation: 2,
          margin: const EdgeInsets.all(12),
          child: Padding(padding: const EdgeInsets.all(4), child: widget),
        ),
      ),
    );
  }
}
