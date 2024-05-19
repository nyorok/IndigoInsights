import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/models/liquidation.dart';
import 'package:indigo_insights/providers/liquidation_provider.dart';
import 'package:indigo_insights/providers/submenu_provider.dart';
import 'package:indigo_insights/theme/color_scheme.dart';
import 'package:indigo_insights/utils/formatters.dart';
import 'package:indigo_insights/utils/loader.dart';
import 'package:pluto_grid/pluto_grid.dart';

class LiquidationsTable extends HookConsumerWidget {
  const LiquidationsTable({super.key});

  List<PlutoColumn> getColumns(String asset) => [
        PlutoColumn(
          title: 'Debt Burned',
          field: 'iAssetBurned',
          type: PlutoColumnType.number(applyFormatOnInit: false),
          width: 180,
          enableColumnDrag: false,
          enableDropToResize: false,
          enableContextMenu: false,
          titlePadding: const EdgeInsets.only(right: 32),
          titleTextAlign: PlutoColumnTextAlign.end,
          textAlign: PlutoColumnTextAlign.end,
          formatter: (value) => "${numberFormatter(value, 6)} $asset",
        ),
        PlutoColumn(
          title: 'Collateral',
          field: 'collateralAbsorbed',
          type: PlutoColumnType.number(applyFormatOnInit: false),
          width: 160,
          enableColumnDrag: false,
          enableDropToResize: false,
          enableContextMenu: false,
          titlePadding: const EdgeInsets.only(right: 32),
          titleTextAlign: PlutoColumnTextAlign.end,
          textAlign: PlutoColumnTextAlign.end,
          formatter: (value) => "${numberFormatter(value, 2)} ADA",
        ),
        PlutoColumn(
          title: 'Oracle Price',
          field: 'oraclePrice',
          type: PlutoColumnType.number(applyFormatOnInit: false),
          width: 160,
          enableColumnDrag: false,
          enableDropToResize: false,
          enableContextMenu: false,
          titlePadding: const EdgeInsets.only(right: 32),
          titleTextAlign: PlutoColumnTextAlign.end,
          textAlign: PlutoColumnTextAlign.end,
          formatter: (value) => "${numberFormatter(value, 6)} ADA",
        ),
        PlutoColumn(
          title: 'ADA Price',
          field: 'adaPrice',
          type: PlutoColumnType.text(),
          width: 160,
          enableColumnDrag: false,
          enableDropToResize: false,
          enableContextMenu: false,
          titlePadding: const EdgeInsets.only(right: 32),
          titleTextAlign: PlutoColumnTextAlign.end,
          textAlign: PlutoColumnTextAlign.end,
          formatter: (value) => "${numberFormatter(value, 6)} USD",
        ),
        PlutoColumn(
          title: 'Liquidated At',
          field: 'createdAt',
          type: PlutoColumnType.date(format: 'MMMM d, y hh:mm a'),
          width: 210,
          enableColumnDrag: false,
          enableDropToResize: false,
          enableContextMenu: false,
          titlePadding: const EdgeInsets.only(right: 32),
          titleTextAlign: PlutoColumnTextAlign.end,
          textAlign: PlutoColumnTextAlign.end,
        )
      ];

  List<PlutoRow> mapToPlutoRow(List<Liquidation> liquidations) {
    return liquidations
        .map((liq) => PlutoRow(cells: {
              "collateralAbsorbed": PlutoCell(value: liq.collateralAbsorbed),
              "iAssetBurned": PlutoCell(value: liq.iAssetBurned),
              "oraclePrice": PlutoCell(value: liq.oraclePrice),
              "adaPrice": PlutoCell(value: liq.adaPrice),
              "createdAt": PlutoCell(value: liq.createdAt),
            }))
        .toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asset =
        ref.watch(selectedLiquidationsSubmenuProvider)?.asset ?? "iUSD";
    final liquidations = ref.watch(liquidationProvider);

    return liquidations.when(
      loading: () => const Loader(),
      error: (err, stack) {
        return Text('Error: $err');
      },
      data: (liquidations) {
        return PlutoGrid(
            key: Key(asset),
            mode: PlutoGridMode.readOnly,
            columns: getColumns(asset),
            rows: mapToPlutoRow(
                liquidations.where((liq) => liq.asset == asset).toList()),
            configuration: getPlutusConfig());
      },
    );
  }

  getPlutusConfig() => PlutoGridConfiguration(
        scrollbar:
            PlutoGridScrollbarConfig(scrollBarColor: colorScheme.onTertiary),
        style: PlutoGridStyleConfig(
          columnAscendingIcon: const Icon(
            Icons.arrow_upward,
            size: 16,
          ),
          columnDescendingIcon: const Icon(
            Icons.arrow_downward,
            size: 16,
          ),
          enableCellBorderVertical: false,
          enableColumnBorderVertical: false,
          menuBackgroundColor: colorScheme.primary,
          gridBackgroundColor: colorScheme.primary,
          rowColor: colorScheme.primary,
          gridBorderRadius: BorderRadius.circular(8),
          cellTextStyle: TextStyle(color: colorScheme.onPrimary),
          columnTextStyle: TextStyle(color: colorScheme.onPrimary),
          iconColor: colorScheme.onPrimary,
          activatedColor: colorScheme.surface,
          borderColor: colorScheme.surface,
          gridBorderColor: colorScheme.surface,
          activatedBorderColor: colorScheme.onTertiary,
        ),
      );
}
