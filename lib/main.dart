import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/providers/indigo_asset_provider.dart';
import 'package:indigo_insights/theme/color_scheme.dart';
import 'package:indigo_insights/views/insights/cdp/cdp_insights.dart';
import 'package:indigo_insights/views/insights/liquidation/liquidation_insights.dart';
import 'package:indigo_insights/views/insights/market/market_insights.dart';
import 'package:indigo_insights/views/insights/stability_pool/stability_pool_insights.dart';
import 'package:indigo_insights/views/insights/stability_pool_account/stability_pool_account_insights.dart';
import 'package:indigo_insights/views/insights/indy_staking/indy_staking_insights.dart';
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
          title: Row(
            children: [
              const Text('Indigo Insights'),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'By ',
                      style: TextStyle(
                        fontSize: 9,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    Image.asset(
                      'assets/pwg-40.png',
                      width: 20,
                      height: 20,
                    ),
                  ],
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
              child: switch (selectedMenuItem.value) {
                0 => const LiquidationInsights(),
                1 => const CdpInsights(),
                2 => const IndyStakingInsights(),
                3 => const StabilityPoolInsights(),
                4 => const StabilityPoolAccountInsights(),
                5 => const MarketInsights(),
                6 => centeredPageContainer(const LiquidationsTable()),
                7 => centeredPageContainer(const CdpsTable()),
                _ => Text("Invalid Page: ${selectedMenuItem.value}"),
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
          MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
        if (states.contains(MaterialState.hovered)) {
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
