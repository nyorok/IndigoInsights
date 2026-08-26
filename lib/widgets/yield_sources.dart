import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:indigo_insights/api/danogo_api/danogo_service.dart';
import 'package:indigo_insights/api/surf_api/surf_lending_service.dart';
import 'package:indigo_insights/models/liquidity_pool_yield.dart';
import 'package:indigo_insights/repositories/apr_repository.dart';
import 'package:indigo_insights/repositories/danogo_pool_repository.dart';
import 'package:indigo_insights/repositories/dex_yield_repository.dart';
import 'package:indigo_insights/repositories/indigo_asset_repository.dart';
import 'package:indigo_insights/repositories/liqwid_market_repository.dart';
import 'package:indigo_insights/repositories/strategy_repository.dart';
import 'package:indigo_insights/repositories/surf_pool_repository.dart';
import 'package:indigo_insights/service_locator.dart';
import 'package:indigo_insights/theme/app_color_scheme.dart';
import 'package:indigo_insights/theme/app_text_styles.dart';
import 'package:indigo_insights/widgets/ii_card.dart';
import 'package:url_launcher/url_launcher.dart';

/// Why the Indigo Orderbook (ROB) exists — shown as an info tooltip.
const robDescription =
    'Indigo Orderbook (ROB) incentivises tradable liquidity instead of raw '
    'TVL. AMM v2 DEX pools incur high slippage even when deep (a 10k swap '
    'against 1M liquidity still slips), which hurts the peg and real use '
    'cases — most liquidity on other chains has already moved to '
    'concentrated forms. ROB rewards liquidity that is actually quotable at '
    'market price.';

const yieldSafeColor = Color(0xFF00ACC1);
const yieldModerateColor = Color(0xFFFF8F00);

/// Dapp shortcut target for a yield row (favicon + open-in-new-tab).
class YieldDapp {
  final String icon;
  final String url;
  const YieldDapp(this.icon, this.url);

  bool get isSvg => icon.endsWith('.svg');

  static const indigo = YieldDapp(
    'assets/images/dapps/indigo.png',
    'https://app.indigoprotocol.io/earn',
  );
  static const indigoRob = YieldDapp(
    'assets/images/dapps/indigo.png',
    'https://app.indigoprotocol.io/order-book',
  );
  static const liqwid = YieldDapp(
    'assets/images/dapps/liqwid.png',
    'https://app.liqwid.finance/',
  );
  static const danogo = YieldDapp(
    'assets/images/dapps/danogo.svg',
    'https://dano.finance/market',
  );
  static const surf = YieldDapp(
    'assets/images/dapps/surf.png',
    'https://surflending.org/app',
  );
  static const sundae = YieldDapp(
    'assets/images/dapps/sundae.png',
    'https://app.sundae.fi/yield-farming',
  );
  static const minswap = YieldDapp(
    'assets/images/dapps/minswap.png',
    'https://minswap.org/farm',
  );
  static const wingriders = YieldDapp(
    'assets/images/dapps/wingriders.svg',
    'https://app.wingriders.com/farming/all-farms',
  );

  static YieldDapp? forDex(Dex dex) => switch (dex) {
        Dex.sundaeswapV3 => sundae,
        Dex.minswapV2 || Dex.minswapStableSwap => minswap,
        Dex.wingridersV2 => wingriders,
        Dex.unknown => null,
      };
}

class YieldRow {
  final String token;
  final String type;
  final double apr;
  final String riskLabel;
  final Color riskColor;
  final String? description;
  final YieldDapp? dapp;

  YieldRow({
    required this.token,
    required this.type,
    required this.apr,
    required this.riskLabel,
    required this.riskColor,
    this.description,
    this.dapp,
  });
}

/// Indigo-related tickers: runtime iAsset list + INDY.
Future<Set<String>> _indigoRelated() async {
  final assets = await sl<IndigoAssetRepository>().getAssets();
  return {...assets.map((a) => a.asset), 'INDY'};
}

/// One independent loader per yield source. Callers run them concurrently so
/// results fill in as each request finishes and a failing third-party API
/// only loses its own rows. All underlying repositories are TTL-cached.
List<Future<List<YieldRow>> Function()> yieldSourceTasks() => [
      () async {
        final spFarming =
            await sl<StrategyRepository>().getStabilityPoolFarmingData();
        final seen = <String>{};
        return [
          for (final sp in spFarming)
            if (seen.add(sp.title))
              YieldRow(
                token: sp.title,
                type: 'Stability Pool',
                apr: sp.poolYield,
                riskLabel: 'Safer',
                riskColor: yieldSafeColor,
                dapp: YieldDapp.indigo,
              ),
        ];
      },
      () async {
        final aprs = await sl<AprRepository>().getAprs();
        return [
          for (final e in aprs.entries)
            if (e.key.startsWith('rob_'))
              YieldRow(
                token: e.key.substring(4),
                type: 'Order Book (RoB)',
                apr: e.value,
                riskLabel: 'Moderate',
                riskColor: yieldModerateColor,
                description: robDescription,
                dapp: YieldDapp.indigoRob,
              ),
          if ((aprs['stake_indy'] ?? 0) > 0)
            YieldRow(
              token: 'INDY',
              type: 'Staking',
              apr: aprs['stake_indy']!,
              riskLabel: 'Safer',
              riskColor: yieldSafeColor,
              dapp: YieldDapp.indigo,
            ),
          if ((aprs['stake_ada'] ?? 0) > 0)
            YieldRow(
              token: 'ADA',
              type: 'Staking',
              apr: aprs['stake_ada']!,
              riskLabel: 'Safer',
              riskColor: yieldSafeColor,
              dapp: YieldDapp.indigo,
            ),
        ];
      },
      () async {
        final related = await _indigoRelated();
        final pools = await sl<DexYieldRepository>().getYields();
        // Token column shows the Indigo-related side of the pair.
        String tokenOf(String pair) => pair
            .split('/')
            .firstWhere(related.contains, orElse: () => pair.split('/').first);
        return [
          for (final pool in pools)
            YieldRow(
              token: tokenOf(pool.pair),
              type: 'Liquidity Pool (${pool.pair})',
              apr: pool.tradingFeesApr + pool.farmingApr,
              riskLabel: 'Moderate',
              riskColor: yieldModerateColor,
              dapp: YieldDapp.forDex(pool.dex),
            ),
        ];
      },
      () async {
        final related = await _indigoRelated();
        final markets = await sl<LiqwidMarketRepository>().getMarkets();
        return [
          for (final m in markets)
            if (related.contains(m.displayName))
              YieldRow(
                token: m.displayName,
                type: 'Lending (Supply)',
                apr: m.supplyApyPercent,
                riskLabel: 'Safer',
                riskColor: yieldSafeColor,
                dapp: YieldDapp.liqwid,
              ),
        ];
      },
      () async {
        final related = await _indigoRelated();
        final pools = await sl<DanogoPoolRepository>().getPools();
        final best = <String, DanogoPool>{};
        for (final p in pools) {
          if (!related.contains(p.ticker)) continue;
          if ((best[p.ticker]?.supplyApyPercent ?? -1) < p.supplyApyPercent) {
            best[p.ticker] = p;
          }
        }
        return [
          for (final p in best.values)
            YieldRow(
              token: p.ticker,
              type: 'Lending (Supply)',
              apr: p.supplyApyPercent,
              riskLabel: 'Safer',
              riskColor: yieldSafeColor,
              dapp: YieldDapp.danogo,
            ),
        ];
      },
      () async {
        final related = await _indigoRelated();
        final pools = await sl<SurfPoolRepository>().getPools();
        final best = <String, SurfPool>{};
        for (final p in pools) {
          if (!related.contains(p.ticker)) continue;
          if ((best[p.ticker]?.supplyApyPercent ?? -1) < p.supplyApyPercent) {
            best[p.ticker] = p;
          }
        }
        return [
          for (final p in best.values)
            YieldRow(
              token: p.ticker,
              type: 'Lending (Supply)',
              apr: p.supplyApyPercent,
              riskLabel: 'Safer',
              riskColor: yieldSafeColor,
              dapp: YieldDapp.surf,
            ),
        ];
      },
    ];

// ─── Dapp Shortcut ────────────────────────────────────────────────────────────

/// Favicon + open-in-new-tab icon that opens the dapp in another tab.
class DappShortcut extends StatelessWidget {
  final YieldDapp dapp;
  final AppColorScheme colors;

  const DappShortcut({super.key, required this.dapp, required this.colors});

  static const _faviconSize = 22.0;

  @override
  Widget build(BuildContext context) {
    final favicon = dapp.isSvg
        ? SvgPicture.asset(dapp.icon, width: _faviconSize, height: _faviconSize)
        : Image.asset(
            dapp.icon,
            width: _faviconSize,
            height: _faviconSize,
            filterQuality: FilterQuality.medium,
          );

    return Tooltip(
      message: 'Open ${Uri.parse(dapp.url).host}',
      waitDuration: const Duration(milliseconds: 300),
      // Transparent Material so the InkWell hover/splash renders identically
      // wherever the shortcut is used (DataTable cells, cards, …).
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          hoverColor: colors.surfaceRaised,
          onTap: () => launchUrl(
            Uri.parse(dapp.url),
            mode: LaunchMode.externalApplication,
            webOnlyWindowName: '_blank',
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: favicon,
                ),
                const SizedBox(width: 5),
                Icon(Icons.open_in_new, size: 17, color: colors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Top Yields Card ──────────────────────────────────────────────────────────

/// Self-contained "Top Yields" card: loads every yield source (progressively)
/// and shows the best five. Reused by the Yield Optimizer and the Dashboard;
/// repositories are TTL-cached so extra instances don't refetch.
class TopYieldsCard extends StatefulWidget {
  const TopYieldsCard({super.key});

  @override
  State<TopYieldsCard> createState() => _TopYieldsCardState();
}

class _TopYieldsCardState extends State<TopYieldsCard> {
  final List<YieldRow> _rows = [];
  int _pending = 0;

  @override
  void initState() {
    super.initState();
    for (final task in yieldSourceTasks()) {
      _pending++;
      task().then((rows) {
        if (!mounted) return;
        setState(() {
          _pending--;
          _rows.addAll(rows);
        });
      }).catchError((Object _) {
        if (!mounted) return;
        setState(() => _pending--);
      });
    }
  }

  @override
  Widget build(BuildContext context) =>
      TopYieldsCardView(rows: _rows, loading: _pending > 0);
}

/// Renders the "Top Yields" card from an externally managed row list.
class TopYieldsCardView extends StatelessWidget {
  final List<YieldRow> rows;
  final bool loading;
  const TopYieldsCardView({
    super.key,
    required this.rows,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final styles = AppTextStyles.of(context);
    final sorted = [...rows]..sort((a, b) => b.apr.compareTo(a.apr));
    final top = sorted.where((r) => r.apr > 0).take(5).toList();

    return IICard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top Yields', style: styles.cardTitle),
          const SizedBox(height: 12),
          if (top.isEmpty && !loading)
            const Text('No positive yields available.')
          else if (top.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.primary,
                  ),
                ),
              ),
            )
          else
            ...top.mapIndexed(
              (i, row) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 11,
                      backgroundColor: colors.success.withValues(alpha: 0.2),
                      child: Text(
                        '${i + 1}',
                        style: styles.monoSm.copyWith(color: colors.success),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            row.token,
                            style: styles.bodySm,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            row.type,
                            style: styles.bodySm.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${row.apr.toStringAsFixed(2)}%',
                      style: styles.kpiValue.copyWith(color: colors.success),
                    ),
                    if (row.dapp != null) ...[
                      const SizedBox(width: 6),
                      DappShortcut(dapp: row.dapp!, colors: colors),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    ).animate().slideX(begin: 0.2, duration: 400.ms).fade(duration: 400.ms);
  }
}
