import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/models/cdp.dart';
import 'package:indigo_insights/providers/cdp_provider.dart';
import 'package:indigo_insights/providers/submenu_provider.dart';
import 'package:indigo_insights/theme/color_scheme.dart';
import 'package:indigo_insights/utils/formatters.dart';
import 'package:indigo_insights/utils/loader.dart';
import 'package:pluto_grid/pluto_grid.dart';

class CdpsTable extends HookConsumerWidget {
  const CdpsTable({Key? key}) : super(key: key);

  List<PlutoColumn> getColumns(String asset) => [
        PlutoColumn(
          title: 'Minted',
          field: 'mintedAmount',
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
          field: 'collateralAmount',
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
          title: 'Transaction',
          field: 'outputHash',
          type: PlutoColumnType.text(),
          width: 530,
          enableColumnDrag: false,
          enableDropToResize: false,
          enableContextMenu: false,
          titlePadding: const EdgeInsets.only(right: 32),
          titleTextAlign: PlutoColumnTextAlign.end,
          textAlign: PlutoColumnTextAlign.end,
        )
      ];

  List<PlutoRow> mapToPlutoRow(List<Cdp> cdps) {
    return cdps
        .map((cdp) => PlutoRow(cells: {
              "asset": PlutoCell(value: cdp.asset),
              "mintedAmount": PlutoCell(value: cdp.mintedAmount),
              "collateralAmount": PlutoCell(value: cdp.collateralAmount),
              "outputHash": PlutoCell(value: cdp.outputHash),
            }))
        .toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asset = ref.watch(selectedCdpsSubmenuProvider)?.asset ?? "iUSD";
    final cdps = ref.watch(cdpsProvider);

    return cdps.when(
      loading: () => const Loader(),
      error: (err, stack) {
        return Text('Error: $err');
      },
      data: (cdps) {
        return PlutoGrid(
            key: Key(asset),
            columns: getColumns(asset),
            rows:
                mapToPlutoRow(cdps.where((cdp) => cdp.asset == asset).toList()),
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
          activatedColor: colorScheme.onBackground,
          borderColor: colorScheme.onBackground,
          gridBorderColor: colorScheme.onBackground,
          activatedBorderColor: colorScheme.onTertiary,
        ),
      );
}
