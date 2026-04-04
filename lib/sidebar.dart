import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indigo_insights/theme/app_color_scheme.dart';
import 'package:indigo_insights/theme/app_text_styles.dart';
import 'package:indigo_insights/theme/gradients.dart';

enum SidebarMenu {
  dashboard,
  strategy,
  yieldOptimizer,
  liquidation,
  redemption,
  indyStaking,
  stabilityPool,
  stabilityPoolAccount,
  cdpExplorer,
  positionSimulator,
}

/// Permanent 240-px sidebar matching the Pencil design.
/// Not a [Drawer] — rendered inline in the shell [Row].
class Sidebar extends StatelessWidget {
  const Sidebar({
    super.key,
    required this.selectedMenu,
    required this.onMenuItemPressed,
  });

  final int selectedMenu;
  final ValueChanged<int> onMenuItemPressed;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final styles = AppTextStyles.of(context);

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(right: BorderSide(color: colors.border, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Logo area ──────────────────────────────────────────────────────
          _LogoArea(styles: styles, colors: colors),
          // ── Nav list ──────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _DonationFooter(styles: styles, colors: colors),
                  _SectionLabel(
                    label: 'OVERVIEW',
                    styles: styles,
                    colors: colors,
                  ),
                  _NavItem(
                    label: 'Protocol Dashboard',
                    menuIndex: SidebarMenu.dashboard.index,
                    selectedMenu: selectedMenu,
                    onTap: onMenuItemPressed,
                    styles: styles,
                    colors: colors,
                  ),
                  _SectionLabel(
                    label: 'STRATEGIES',
                    styles: styles,
                    colors: colors,
                  ),
                  _NavItem(
                    label: 'Strategy',
                    menuIndex: SidebarMenu.strategy.index,
                    selectedMenu: selectedMenu,
                    onTap: onMenuItemPressed,
                    styles: styles,
                    colors: colors,
                  ),
                  _NavItem(
                    label: 'Yield Optimizer',
                    menuIndex: SidebarMenu.yieldOptimizer.index,
                    selectedMenu: selectedMenu,
                    onTap: onMenuItemPressed,
                    styles: styles,
                    colors: colors,
                  ),
                  _SectionLabel(
                    label: 'ANALYTICS',
                    styles: styles,
                    colors: colors,
                  ),
                  _NavItem(
                    label: 'Liquidation',
                    menuIndex: SidebarMenu.liquidation.index,
                    selectedMenu: selectedMenu,
                    onTap: onMenuItemPressed,
                    styles: styles,
                    colors: colors,
                  ),
                  _NavItem(
                    label: 'Redemption',
                    menuIndex: SidebarMenu.redemption.index,
                    selectedMenu: selectedMenu,
                    onTap: onMenuItemPressed,
                    styles: styles,
                    colors: colors,
                  ),
                  _NavItem(
                    label: 'Indy Staking',
                    menuIndex: SidebarMenu.indyStaking.index,
                    selectedMenu: selectedMenu,
                    onTap: onMenuItemPressed,
                    styles: styles,
                    colors: colors,
                  ),
                  _NavItem(
                    label: 'Stability Pool',
                    menuIndex: SidebarMenu.stabilityPool.index,
                    selectedMenu: selectedMenu,
                    onTap: onMenuItemPressed,
                    styles: styles,
                    colors: colors,
                  ),
                  _NavItem(
                    label: 'SP Account',
                    menuIndex: SidebarMenu.stabilityPoolAccount.index,
                    selectedMenu: selectedMenu,
                    onTap: onMenuItemPressed,
                    styles: styles,
                    colors: colors,
                  ),
                  _SectionLabel(label: 'TOOLS', styles: styles, colors: colors),
                  _NavItem(
                    label: 'CDP Explorer',
                    menuIndex: SidebarMenu.cdpExplorer.index,
                    selectedMenu: selectedMenu,
                    onTap: onMenuItemPressed,
                    styles: styles,
                    colors: colors,
                  ),
                  _NavItem(
                    label: 'Position Simulator',
                    menuIndex: SidebarMenu.positionSimulator.index,
                    selectedMenu: selectedMenu,
                    onTap: onMenuItemPressed,
                    styles: styles,
                    colors: colors,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────────

class _LogoArea extends StatelessWidget {
  const _LogoArea({required this.styles, required this.colors});

  final AppTextStyles styles;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.border, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/icons/ic_square_512.png',
              width: 28,
              height: 28,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
              cacheWidth: 56,
              cacheHeight: 56,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Indigo Insights',
            style: styles.cardTitle.copyWith(color: colors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.label,
    required this.styles,
    required this.colors,
  });

  final String label;
  final AppTextStyles styles;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 16, bottom: 4),
      child: Text(
        label,
        style: styles.sectionLabel.copyWith(color: colors.textMuted),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.menuIndex,
    required this.selectedMenu,
    required this.onTap,
    required this.styles,
    required this.colors,
  });

  final String label;
  final int menuIndex;
  final int selectedMenu;
  final ValueChanged<int> onTap;
  final AppTextStyles styles;
  final AppColorScheme colors;

  bool get _isSelected => selectedMenu == menuIndex;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => onTap(menuIndex),
          child: Container(
            decoration: _isSelected
                ? BoxDecoration(
                    gradient: accentSelectionGradient,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.primaryBorder, width: 1),
                  )
                : BoxDecoration(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Text(
              label,
              style: _isSelected
                  ? styles.bodyMd.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w600,
                    )
                  : styles.bodyMd.copyWith(color: colors.textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Donation Footer ────────────────────────────────────────────────────────────

class _DonationFooter extends StatefulWidget {
  const _DonationFooter({required this.styles, required this.colors});
  final AppTextStyles styles;
  final AppColorScheme colors;

  @override
  State<_DonationFooter> createState() => _DonationFooterState();
}

class _DonationFooterState extends State<_DonationFooter> {
  static const _addr =
      'addr1qxjalxzyptawry6aglve6awl5dw9athelw66zta3kumgf07my5zpph5fyjj8y2g8e4w2y7hqhksprd7l28h5kppaspxsfenzek';

  bool _copied = false;

  void _copy() async {
    await Clipboard.setData(const ClipboardData(text: _addr));
    setState(() => _copied = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    final styles = widget.styles;
    final colors = widget.colors;
    final shortAddr =
        '${_addr.substring(0, 12)}…${_addr.substring(_addr.length - 6)}';

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.border, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Support Development',
            style: styles.sectionLabel.copyWith(color: colors.textMuted),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  shortAddr,
                  style: styles.monoSm.copyWith(color: colors.primary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Tooltip(
                message: _copied ? 'Copied!' : 'Copy address',
                child: InkWell(
                  onTap: _copy,
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      _copied ? Icons.check : Icons.copy_outlined,
                      size: 14,
                      color: _copied ? colors.success : colors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
