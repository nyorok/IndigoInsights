import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/providers/indigo_asset_provider.dart';
import 'package:indigo_insights/theme/color_scheme.dart';
import 'package:indigo_insights/theme/gradients.dart';
import 'package:indigo_insights/utils/page_title.dart';
import 'package:indigo_insights/views/insights/cdp/cdp_insights.dart';
import 'package:indigo_insights/views/insights/cdp_position/cdp_position_insights.dart';
import 'package:indigo_insights/views/insights/indy_staking/indy_staking_insights.dart';
import 'package:indigo_insights/views/insights/liquidation/liquidation_insights.dart';
import 'package:indigo_insights/views/insights/market/market_insights.dart';
import 'package:indigo_insights/views/insights/minted_supply/minted_supply_insights.dart';
import 'package:indigo_insights/views/insights/redemption/redemption_insights.dart';
import 'package:indigo_insights/views/insights/stability_pool/stability_pool_insights.dart';
import 'package:indigo_insights/views/insights/stability_pool_account/stability_pool_account_insights.dart';

import 'sidebar.dart';
import 'utils/loader.dart';

void main() async {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends HookConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMenuItem = useState(SidebarMenu.mintedSupply.index);

    return MaterialApp(
      title: 'Indigo Insights',
      theme: getTheme(context),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: colorScheme.surfaceContainerLow,
          title: Row(
            children: [
              PageTitle(title: 'Indigo Insights', fontSize: 22),
              const SizedBox(width: 3),
            ],
          ),
          leading: Builder(
            builder: (innerContext) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(innerContext).openDrawer(),
            ),
          ),
        ),
        drawer: ref
            .watch(indigoAssetsProvider)
            .when(
              loading: () => const Loader(),
              error: (err, stack) => Text('Error: $err'),
              data: (assets) => Sidebar(
                onMenuItemPressed: (value) => selectedMenuItem.value = value,
                selectedMenu: selectedMenuItem.value,
                assets: assets,
              ),
            ),
        body: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(gradient: indigoDarkGradient),
                child: switch (SidebarMenu.values[selectedMenuItem.value]) {
                  SidebarMenu.cdpPosition => const CdpPositionInsights(),
                  SidebarMenu.liquidation => const LiquidationInsights(),
                  SidebarMenu.cdps => const CdpInsights(),
                  SidebarMenu.mintedSupply => const MintedSupplyInsights(),
                  SidebarMenu.indyStaking => const IndyStakingInsights(),
                  SidebarMenu.redemption => const RedemptionInsights(),
                  SidebarMenu.stabilityPool => const StabilityPoolInsights(),
                  SidebarMenu.stabilityPoolAccount =>
                    const StabilityPoolAccountInsights(),
                  SidebarMenu.market => const MarketInsights(),
                },
              ),
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
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.hovered)) {
            return Theme.of(context).colorScheme.primary.withValues(alpha: .08);
          }
          return null;
        }),
      ),
      colorScheme: colorScheme,
      useMaterial3: true,
    );
  }
}
