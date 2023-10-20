import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/models/indigo_asset.dart';
import 'package:indigo_insights/providers/submenu_provider.dart';

class Sidebar extends ConsumerWidget {
  final Function(int) onMenuItemPressed;
  final int selectedMenu;
  final List<IndigoAsset> assets;

  const Sidebar(
      {Key? key,
      required this.onMenuItemPressed,
      required this.selectedMenu,
      required this.assets})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    getInsigoInsightsTitle() {
      return SafeArea(
        child: Container(
          height: 60,
          margin: const EdgeInsets.only(),
          padding: const EdgeInsets.all(16),
          child: const Text('Indigo Insights',
              style: TextStyle(fontSize: 12.8, fontWeight: FontWeight.w500)),
        ),
      );
    }

    ListTile getListTile({required String title, required int menuIndex}) {
      return ListTile(
        selected: selectedMenu == menuIndex,
        selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        title: Text(title,
            style: TextStyle(
                color: selectedMenu == menuIndex
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context).colorScheme.onTertiary,
                fontSize: 12.8)),
        onTap: () => onMenuItemPressed(menuIndex),
      );
    }

    Card getExpansionTile(
        {required String title,
        required int menuIndex,
        required List<Widget> children}) {
      return Card(
        elevation: 0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        child: ExpansionTile(
          title: Text(title,
              style: TextStyle(
                  color: selectedMenu == menuIndex
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(context).colorScheme.onTertiary,
                  fontSize: 12.8)),
          children: children,
        ),
      );
    }

    ListTile getSubmenuListTile<Submenu>(
        {required Submenu submenu,
        required String Function(Submenu) getTitle,
        required int menuIndex,
        required Submenu? selectedSubmenu,
        required Function(Submenu) setSubmenu}) {
      return ListTile(
        selected: selectedSubmenu == submenu && selectedMenu == menuIndex,
        selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        title: Text(getTitle(submenu),
            style: TextStyle(
                color: selectedSubmenu == submenu && selectedMenu == menuIndex
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context).colorScheme.onTertiary,
                fontSize: 12.8)),
        onTap: () {
          onMenuItemPressed(menuIndex);
          setSubmenu(submenu);
        },
      );
    }

    return Drawer(
      width: 240,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          getInsigoInsightsTitle(),
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Text(
              "Insights",
              style: TextStyle(color: Theme.of(context).colorScheme.onTertiary),
            ),
          ),
          getListTile(title: 'Liquidation', menuIndex: 0),
          getListTile(title: 'CDP', menuIndex: 1),
          getListTile(title: 'Indy Staking', menuIndex: 2),
          getListTile(title: 'Stability Pool', menuIndex: 3),
          getListTile(title: 'Stability Pool Account', menuIndex: 4),
          getListTile(title: 'Market', menuIndex: 5),
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Text(
              "Tables",
              style: TextStyle(color: Theme.of(context).colorScheme.onTertiary),
            ),
          ),
          getExpansionTile(
            title: 'Liquidations',
            menuIndex: 6,
            children: assets
                .map((submenu) => getSubmenuListTile(
                      submenu: submenu,
                      getTitle: IndigoInsightsMenu.getIndigoAssetSubmenu,
                      menuIndex: 6,
                      selectedSubmenu:
                          ref.watch(selectedLiquidationsSubmenuProvider),
                      setSubmenu: (submenu) => ref
                          .read(selectedLiquidationsSubmenuProvider.notifier)
                          .state = submenu,
                    ))
                .toList(),
          ),
          getExpansionTile(
            title: "CDPs",
            menuIndex: 7,
            children: assets
                .map((submenu) => getSubmenuListTile(
                      submenu: submenu,
                      getTitle: IndigoInsightsMenu.getIndigoAssetSubmenu,
                      menuIndex: 7,
                      selectedSubmenu: ref.watch(selectedCdpsSubmenuProvider),
                      setSubmenu: (submenu) => ref
                          .read(selectedCdpsSubmenuProvider.notifier)
                          .state = submenu,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
