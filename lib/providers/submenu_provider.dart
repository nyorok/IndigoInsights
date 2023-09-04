import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indigo_insights/models/indigo_asset.dart';

enum ChartSubmenu {
  stakedIndy,
  cumulativeLiquidations,
  stabililyPoolSolvencyIUsd,
  stabililyPoolSolvencyIBtc,
  stabililyPoolSolvencyIEth
}

abstract class IndigoInsightsMenu {
  static String getIndigoAssetSubmenu(IndigoAsset indigoAsset) =>
      indigoAsset.asset;

  static String getChartSubmenu(ChartSubmenu submenu) => switch (submenu) {
        ChartSubmenu.stakedIndy => "Staked Indy",
        ChartSubmenu.cumulativeLiquidations => "Cumulative Liquidations",
        ChartSubmenu.stabililyPoolSolvencyIUsd =>
          "Stability Pool Solvency (iUSD)",
        ChartSubmenu.stabililyPoolSolvencyIBtc =>
          "Stability Pool Solvency (iBTC)",
        ChartSubmenu.stabililyPoolSolvencyIEth =>
          "Stability Pool Solvency (iETH)",
      };

  static String getChartSubmenuNullable(ChartSubmenu? submenu) =>
      submenu == null ? '' : getChartSubmenu(submenu);
}

final selectedLiquidationsSubmenuProvider =
    StateProvider<IndigoAsset?>((ref) => null);
final selectedCdpsSubmenuProvider = StateProvider<IndigoAsset?>((ref) => null);

final selectedChartSubmenuProvider =
    StateProvider<ChartSubmenu?>((ref) => null);
final selectedDistributionSubmenuProvider =
    StateProvider<IndigoAsset?>((ref) => null);
final selectedUnclaimedRewardsSubmenuProvider =
    StateProvider<IndigoAsset?>((ref) => null);
final selectedMarketDistributionSubmenuProvider =
    StateProvider<IndigoAsset?>((ref) => null);
