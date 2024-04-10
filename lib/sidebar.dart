import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/models/indigo_asset.dart';
import 'package:indigo_insights/providers/submenu_provider.dart';
import 'package:indigo_insights/utils/page_title.dart';
import 'package:url_launcher/link.dart';

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
      return SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/logo-48.png', width: 30, height: 30),
            Row(
              children: [
                const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: PageTitle(title: 'Indigo Insights')),
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
          ],
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
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  getInsigoInsightsTitle(),
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 4),
                    child: Text(
                      "Insights",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onTertiary),
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
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onTertiary),
                    ),
                  ),
                  getExpansionTile(
                    title: 'Liquidations',
                    menuIndex: 6,
                    children: assets
                        .map((submenu) => getSubmenuListTile(
                              submenu: submenu,
                              getTitle:
                                  IndigoInsightsMenu.getIndigoAssetSubmenu,
                              menuIndex: 6,
                              selectedSubmenu: ref
                                  .watch(selectedLiquidationsSubmenuProvider),
                              setSubmenu: (submenu) => ref
                                  .read(selectedLiquidationsSubmenuProvider
                                      .notifier)
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
                              getTitle:
                                  IndigoInsightsMenu.getIndigoAssetSubmenu,
                              menuIndex: 7,
                              selectedSubmenu:
                                  ref.watch(selectedCdpsSubmenuProvider),
                              setSubmenu: (submenu) => ref
                                  .read(selectedCdpsSubmenuProvider.notifier)
                                  .state = submenu,
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
            Link(
              uri: Uri.parse('https://www.flaticon.com/free-icons/purple-eye'),
              target: LinkTarget.blank,
              builder: (BuildContext ctx, FollowLink? openLink) {
                return TextButton(
                    onPressed: openLink,
                    child: Text(
                      'Icon credits',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.2),
                          fontWeight: FontWeight.normal,
                          fontSize: 9),
                    ));
              },
            )
          ],
        ),
      ),
    );
  }
}
