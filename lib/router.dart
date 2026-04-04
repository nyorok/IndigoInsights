import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:indigo_insights/sidebar.dart';
import 'package:indigo_insights/theme/schemes/dark_scheme.dart';
import 'package:indigo_insights/views/insights/cdp_explorer/cdp_explorer_insights.dart';
import 'package:indigo_insights/views/insights/dashboard/protocol_dashboard.dart';
import 'package:indigo_insights/views/insights/indy_staking/indy_staking_insights.dart';
import 'package:indigo_insights/views/insights/liquidation/liquidation_insights.dart';
import 'package:indigo_insights/views/insights/position_simulator/position_simulator_insights.dart';
import 'package:indigo_insights/views/insights/redemption/redemption_insights.dart';
import 'package:indigo_insights/views/insights/stability_pool/stability_pool_insights.dart';
import 'package:indigo_insights/views/insights/stability_pool_account/stability_pool_account_insights.dart';
import 'package:indigo_insights/views/insights/strategy/strategy_insights.dart';
import 'package:indigo_insights/views/insights/yield_optimizer/yield_optimizer_insights.dart';

/// Route paths — use these constants everywhere instead of raw strings.
class AppRoutes {
  static const dashboard = '/dashboard';
  static const strategy = '/strategy';
  static const yieldOptimizer = '/yield-optimizer';
  static const liquidation = '/liquidation';
  static const redemption = '/redemption';
  static const indyStaking = '/indy-staking';
  static const stabilityPool = '/stability-pool';
  static const spAccount = '/sp-account';
  static const cdpExplorer = '/cdp-explorer';
  static const positionSimulator = '/position-simulator';

  /// Query-param key used on every tabbed page.
  static const tabParam = 'tab';
}

/// Returns the [SidebarMenu] index that matches [location] (path only).
int sidebarIndexForLocation(String location) {
  final path = Uri.parse(location).path;
  return switch (path) {
    AppRoutes.dashboard => SidebarMenu.dashboard.index,
    AppRoutes.strategy => SidebarMenu.strategy.index,
    AppRoutes.yieldOptimizer => SidebarMenu.yieldOptimizer.index,
    AppRoutes.liquidation => SidebarMenu.liquidation.index,
    AppRoutes.redemption => SidebarMenu.redemption.index,
    AppRoutes.indyStaking => SidebarMenu.indyStaking.index,
    AppRoutes.stabilityPool => SidebarMenu.stabilityPool.index,
    AppRoutes.spAccount => SidebarMenu.stabilityPoolAccount.index,
    AppRoutes.cdpExplorer => SidebarMenu.cdpExplorer.index,
    AppRoutes.positionSimulator => SidebarMenu.positionSimulator.index,
    _ => SidebarMenu.dashboard.index,
  };
}

/// Path for a given [SidebarMenu] index.
String routeForSidebarIndex(int index) =>
    switch (SidebarMenu.values[index]) {
      SidebarMenu.dashboard => AppRoutes.dashboard,
      SidebarMenu.strategy => AppRoutes.strategy,
      SidebarMenu.yieldOptimizer => AppRoutes.yieldOptimizer,
      SidebarMenu.liquidation => AppRoutes.liquidation,
      SidebarMenu.redemption => AppRoutes.redemption,
      SidebarMenu.indyStaking => AppRoutes.indyStaking,
      SidebarMenu.stabilityPool => AppRoutes.stabilityPool,
      SidebarMenu.stabilityPoolAccount => AppRoutes.spAccount,
      SidebarMenu.cdpExplorer => AppRoutes.cdpExplorer,
      SidebarMenu.positionSimulator => AppRoutes.positionSimulator,
    };

final appRouter = GoRouter(
  initialLocation: AppRoutes.dashboard,
  routes: [
    ShellRoute(
      builder: (context, state, child) => _AppShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          redirect: (context, state) => AppRoutes.dashboard,
        ),
        GoRoute(
          path: AppRoutes.dashboard,
          pageBuilder: _fade((_) => const ProtocolDashboard()),
        ),
        GoRoute(
          path: AppRoutes.strategy,
          pageBuilder: _fade((_) => const StrategyInsights()),
        ),
        GoRoute(
          path: AppRoutes.yieldOptimizer,
          pageBuilder: _fade((_) => const YieldOptimizerInsights()),
        ),
        GoRoute(
          path: AppRoutes.liquidation,
          pageBuilder: _fade((state) => LiquidationInsights(
                initialTab: state.uri.queryParameters[AppRoutes.tabParam],
              )),
        ),
        GoRoute(
          path: AppRoutes.redemption,
          pageBuilder: _fade((state) => RedemptionInsights(
                initialTab: state.uri.queryParameters[AppRoutes.tabParam],
              )),
        ),
        GoRoute(
          path: AppRoutes.indyStaking,
          pageBuilder: _fade((state) => IndyStakingInsights(
                initialTab: state.uri.queryParameters[AppRoutes.tabParam],
              )),
        ),
        GoRoute(
          path: AppRoutes.stabilityPool,
          pageBuilder: _fade((state) => StabilityPoolInsights(
                initialTab: state.uri.queryParameters[AppRoutes.tabParam],
              )),
        ),
        GoRoute(
          path: AppRoutes.spAccount,
          pageBuilder: _fade((_) => const StabilityPoolAccountInsights()),
        ),
        GoRoute(
          path: AppRoutes.cdpExplorer,
          pageBuilder: _fade((state) => CdpExplorerInsights(
                initialTab: state.uri.queryParameters[AppRoutes.tabParam],
              )),
        ),
        GoRoute(
          path: AppRoutes.positionSimulator,
          pageBuilder: _fade((_) => const PositionSimulatorInsights()),
        ),
      ],
    ),
  ],
);

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Wraps a widget builder in a [CustomTransitionPage] with a quick fade.
GoRouterPageBuilder _fade(Widget Function(GoRouterState state) builder) =>
    (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: builder(state),
          transitionDuration: const Duration(milliseconds: 120),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        );

// ── Shell ─────────────────────────────────────────────────────────────────────

const _kDesktopBreakpoint = 700.0;

class _AppShell extends StatefulWidget {
  const _AppShell({required this.child});
  final Widget child;

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final selectedIndex = sidebarIndexForLocation(location);
    final isDesktop =
        MediaQuery.of(context).size.width >= _kDesktopBreakpoint;

    void navigate(int i) {
      _scaffoldKey.currentState?.closeDrawer();
      context.go(routeForSidebarIndex(i));
    }

    final sidebar = Sidebar(
      selectedMenu: selectedIndex,
      onMenuItemPressed: navigate,
    );

    if (isDesktop) {
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: darkScheme.canvas,
        body: Row(
          children: [
            sidebar,
            Expanded(child: widget.child),
          ],
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: darkScheme.canvas,
      drawer: Drawer(
        width: 240,
        backgroundColor: darkScheme.surface,
        child: sidebar,
      ),
      body: widget.child,
    );
  }
}

/// Helper extension — pushes a [tab] query param to the current location
/// without changing the path.  Call from tab-bar [onTap] callbacks.
extension TabRouting on BuildContext {
  void goTab(String tabName) {
    final state = GoRouterState.of(this);
    final path = state.uri.path;
    go('$path?${AppRoutes.tabParam}=${Uri.encodeComponent(tabName)}');
  }

  /// Current tab name from the URL, or null if absent.
  String? get currentTab =>
      GoRouterState.of(this).uri.queryParameters[AppRoutes.tabParam];
}
