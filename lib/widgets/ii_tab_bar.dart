import 'package:flutter/material.dart';
import 'package:indigo_insights/theme/app_color_scheme.dart';
import 'package:indigo_insights/theme/app_text_styles.dart';
import 'package:indigo_insights/theme/gradients.dart';

/// Design-system tab bar — dark container, active tab uses purple gradient +
/// border matching the CDP Explorer design.
///
/// Wrap with a [DefaultTabController] or pass an explicit [controller].
///
/// Uses Flutter's built-in [TabBar] internally for full accessibility and
/// keyboard navigation support.
class IITabBar extends StatelessWidget implements PreferredSizeWidget {
  const IITabBar({
    super.key,
    this.tabs,
    this.tabWidgets,
    this.controller,
    this.onTap,
  }) : assert(tabs != null || tabWidgets != null,
            'Provide either tabs (strings) or tabWidgets');

  final List<String>? tabs;

  /// Optional: supply fully custom tab child widgets (e.g. text + badge).
  /// When provided, [tabs] is ignored.
  final List<Widget>? tabWidgets;
  final TabController? controller;
  final ValueChanged<int>? onTap;

  @override
  Size get preferredSize => const Size.fromHeight(44);

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final styles = AppTextStyles.of(context);

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: TabBar(
        controller: controller,
        onTap: onTap,
        padding: EdgeInsets.zero,
        tabs: tabWidgets != null
            ? tabWidgets!.map((w) => Tab(height: 36, child: w)).toList()
            : tabs!.map((t) => Tab(text: t, height: 36)).toList(),
        labelStyle: styles.tabLabel.copyWith(color: colors.primary),
        unselectedLabelStyle: styles.tabLabelInactive.copyWith(color: colors.textMuted),
        indicator: BoxDecoration(
          gradient: accentSelectionGradient,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.primaryBorder, width: 1),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
      ),
    );
  }
}
