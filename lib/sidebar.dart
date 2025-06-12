import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/models/indigo_asset.dart';
import 'package:indigo_insights/theme/gradients.dart';
import 'package:indigo_insights/utils/page_title.dart';

enum SidebarMenu {
  cdpPosition,
  mintedSupply,
  cdps,
  liquidation,
  redemption,
  indyStaking,
  stabilityPool,
  stabilityPoolAccount,
  market,
}

class Sidebar extends ConsumerWidget {
  final Function(int) onMenuItemPressed;
  final int selectedMenu;
  final List<IndigoAsset> assets;

  const Sidebar({
    super.key,
    required this.onMenuItemPressed,
    required this.selectedMenu,
    required this.assets,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    getInsigoInsightsTitle() {
      return SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Hero(
              tag: "title_icon",
              child: Image.asset(
                'assets/icons/ic_48.png',
                width: 30,
                height: 30,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: PageTitle(title: 'Indigo Insights'),
            ),
          ],
        ),
      );
    }

    Animate getListTile({required String title, required int menuIndex}) {
      return Container(
        decoration: selectedMenu == menuIndex
            ? BoxDecoration(
                gradient: indigoSelectionGradient,
                borderRadius: BorderRadius.circular(12.0),
              )
            : null,
        child: Material(
          color: Colors.transparent,
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            title: Text(
              title,
              style: TextStyle(
                color: selectedMenu == menuIndex
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context).colorScheme.onTertiary,
                fontSize: 12.8,
              ),
            ),
            onTap: () => onMenuItemPressed(menuIndex),
          ),
        ),
      ).animate().slideX(
        duration: (((menuIndex) + 2) * 100).ms,
        curve: Curves.easeInOut,
      );
    }

    return Drawer(
      width: 240,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
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
                    child:
                        Text(
                          "Insights",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onTertiary,
                          ),
                        ).animate().slideX(
                          duration: 200.ms,
                          curve: Curves.easeInOut,
                        ),
                  ),
                  getListTile(
                    title: 'CDP Position',
                    menuIndex: SidebarMenu.cdpPosition.index,
                  ),
                  getListTile(
                    title: 'Minted Supply',
                    menuIndex: SidebarMenu.mintedSupply.index,
                  ),
                  getListTile(title: 'CDP', menuIndex: SidebarMenu.cdps.index),
                  getListTile(
                    title: 'Liquidation',
                    menuIndex: SidebarMenu.liquidation.index,
                  ),
                  getListTile(
                    title: 'Redemption',
                    menuIndex: SidebarMenu.redemption.index,
                  ),
                  getListTile(
                    title: 'Indy Staking',
                    menuIndex: SidebarMenu.indyStaking.index,
                  ),
                  getListTile(
                    title: 'Stability Pool',
                    menuIndex: SidebarMenu.stabilityPool.index,
                  ),
                  getListTile(
                    title: 'Stability Pool Account',
                    menuIndex: SidebarMenu.stabilityPoolAccount.index,
                  ),
                  getListTile(
                    title: 'Market',
                    menuIndex: SidebarMenu.market.index,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
