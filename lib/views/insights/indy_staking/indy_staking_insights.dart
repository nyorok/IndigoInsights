import 'package:indigo_insights/router.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:indigo_insights/models/stake_history.dart';
import 'package:indigo_insights/repositories/stake_history_repository.dart';
import 'package:indigo_insights/service_locator.dart';
import 'package:indigo_insights/theme/app_color_scheme.dart';
import 'package:indigo_insights/theme/app_text_styles.dart';
import 'package:indigo_insights/utils/async_builder.dart';
import 'package:indigo_insights/utils/formatters.dart';
import 'package:indigo_insights/views/insights/indy_staking/governance_rewards_chart.dart';
import 'package:indigo_insights/views/insights/indy_staking/stake_history_chart.dart';
import 'package:indigo_insights/views/insights/indy_staking/staking_velocity_chart.dart';
import 'package:indigo_insights/widgets/ii_card.dart';
import 'package:indigo_insights/widgets/ii_data_row.dart';
import 'package:indigo_insights/widgets/ii_kpi_strip.dart';
import 'package:indigo_insights/widgets/ii_tab_bar.dart';
import 'package:indigo_insights/widgets/ii_top_bar.dart';

/// Tab name constants for URL routing (`?tab=stake-history` etc.)
const _kStakingTabs = ['stake-history', 'staking-velocity', 'governance-rewards'];

class IndyStakingInsights extends StatefulWidget {
  const IndyStakingInsights({super.key, this.initialTab});

  /// Optional tab name from the `?tab=` URL query parameter.
  final String? initialTab;

  @override
  State<IndyStakingInsights> createState() => _IndyStakingInsightsState();
}

class _IndyStakingInsightsState extends State<IndyStakingInsights>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  int _resolveInitialIndex() {
    final tab = widget.initialTab;
    if (tab != null) {
      final idx = _kStakingTabs.indexOf(tab);
      if (idx >= 0) return idx;
    }
    return 0;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: _resolveInitialIndex(),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const IITopBar(title: 'INDY Staking'),
        Expanded(
          child: AsyncBuilder(
            fetcher: () => sl<StakeHistoryRepository>().getHistory(),
            builder: (history) {
              history.sortBy((s) => s.date);
              return _StakingContent(
                history: history,
                tabController: _tabController,
              );            },
            errorBuilder: (error, retry) =>
                Center(child: Text(error.toString())),
          ),
        ),
      ],
    );
  }
}

class _StakingContent extends StatelessWidget {
  const _StakingContent({required this.history, required this.tabController});

  final List<dynamic> history;
  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final styles = AppTextStyles.of(context);

    if (history.isEmpty) return const Center(child: Text('No data'));

    final typedHistory = history.cast<StakeHistory>();
    final now = DateTime.now();
    final day1 = now.subtract(const Duration(days: 1));
    final day7 = now.subtract(const Duration(days: 7));
    final day30 = now.subtract(const Duration(days: 30));

    final stakeNow = typedHistory.last.staked;
    final stake1d =
        typedHistory.lastWhereOrNull((s) => s.date.isBefore(day1))?.staked ??
            stakeNow;
    final stake7d =
        typedHistory.lastWhereOrNull((s) => s.date.isBefore(day7))?.staked ??
            stakeNow;
    final stake30d =
        typedHistory.lastWhereOrNull((s) => s.date.isBefore(day30))?.staked ??
            stakeNow;

    final d1 = stakeNow - stake1d;
    final d7 = stakeNow - stake7d;
    final d30 = stakeNow - stake30d;

    Color deltaColor(double d) =>
        d >= 0 ? colors.success : colors.error;

    final isDesktop = MediaQuery.of(context).size.width >= 700;

    final kpiStrip = IIKpiStrip(cells: [
      IIKpiCell(
        label: 'Total Staked',
        value: numberAbbreviatedFormatter(stakeNow, getAbbreviation(stakeNow)),
        unit: 'INDY',
      ),
      IIKpiCell(
        label: '1d Delta',
        value:
            '${d1 >= 0 ? '+' : ''}${numberAbbreviatedFormatter(d1, getAbbreviation(d1.abs()))}',
        unit: 'INDY',
        valueColor: deltaColor(d1),
      ),
      IIKpiCell(
        label: '7d Delta',
        value:
            '${d7 >= 0 ? '+' : ''}${numberAbbreviatedFormatter(d7, getAbbreviation(d7.abs()))}',
        unit: 'INDY',
        valueColor: deltaColor(d7),
      ),
      IIKpiCell(
        label: '30d Delta',
        value:
            '${d30 >= 0 ? '+' : ''}${numberAbbreviatedFormatter(d30, getAbbreviation(d30.abs()))}',
        unit: 'INDY',
        valueColor: deltaColor(d30),
      ),
    ]);

    final overviewCard = IICard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Overview', style: styles.cardTitle),
          const SizedBox(height: 12),
          IIDataRow(
            label: 'INDY Staked',
            value: numberFormatter(stakeNow, 0),
            unit: 'INDY',
          ),
          IIDataRow(
            label: '1d Change',
            value: '${d1 >= 0 ? '+' : ''}${numberFormatter(d1, 0)}',
            valueColor: deltaColor(d1),
          ),
          IIDataRow(
            label: '7d Change',
            value: '${d7 >= 0 ? '+' : ''}${numberFormatter(d7, 0)}',
            valueColor: deltaColor(d7),
          ),
          IIDataRow(
            label: '30d Change',
            value: '${d30 >= 0 ? '+' : ''}${numberFormatter(d30, 0)}',
            valueColor: deltaColor(d30),
          ),
        ],
      ),
    );

    final chartsCard = IICard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: IITabBar(
              tabs: const ['Staked History', 'Velocity', 'Gov. Rewards'],
              controller: tabController,
              onTap: (i) => context.goTab(_kStakingTabs[i]),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: const [
                StakeHistoryChart(),
                StakingVelocityChart(),
                GovernanceRewardsChart(),
              ],
            ),
          ),
        ],
      ),
    );

    if (isDesktop) {
      return SelectionArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              kpiStrip,
              const SizedBox(height: 16),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 300, child: overviewCard),
                    const SizedBox(width: 16),
                    Expanded(child: chartsCard),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SelectionArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            kpiStrip,
            const SizedBox(height: 16),
            overviewCard,
            const SizedBox(height: 16),
            SizedBox(height: 380, child: chartsCard),
          ],
        ),
      ),
    );
  }
}
