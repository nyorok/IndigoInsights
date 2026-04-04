# IndigoInsights — Agent Context

Flutter analytics dashboard for Indigo Protocol (Cardano DeFi). Read-only; no wallet or write operations. Supports iUSD, iBTC, iETH, iSOL.

---

## Tech Stack

- Flutter 3.41.5 / Dart SDK ^3.11.0
- DI / State: `get_it` (service locator) + `FutureBuilder` via `AsyncBuilder`
- Charts: `fl_chart`
- HTTP: `package:http`
- Font: Quicksand; theme: Material 3 (`lib/theme/`)

---

## Navigation

`lib/sidebar.dart` — `SidebarMenu` enum is the single source of truth for pages.  
`lib/main.dart` — `switch(SidebarMenu.values[_selectedMenuItem])` renders the active page.

**To add a page:** add an enum value to `SidebarMenu` → add a `getListTile` call in `Sidebar.build` → add an import + switch case in `main.dart`.

Current pages:

| Enum value | View file | Section |
|---|---|---|
| `dashboard` | `lib/views/insights/dashboard/protocol_dashboard.dart` | Overview |
| `strategy` | `lib/views/insights/strategy/strategy_insights.dart` | Strategies |
| `yieldOptimizer` | `lib/views/insights/yield_optimizer/yield_optimizer_insights.dart` | Strategies |
| `liquidation` | `lib/views/insights/liquidation/liquidation_insights.dart` | Analytics |
| `liquidationScenario` | `lib/views/insights/liquidation_scenario/liquidation_scenario_insights.dart` | Analytics |
| `redemption` | `lib/views/insights/redemption/redemption_insights.dart` | Analytics |
| `indyStaking` | `lib/views/insights/indy_staking/indy_staking_insights.dart` | Analytics |
| `stabilityPool` | `lib/views/insights/stability_pool/stability_pool_insights.dart` | Analytics |
| `stabilityPoolAccount` | `lib/views/insights/stability_pool_account/stability_pool_account_insights.dart` | Analytics |
| `cdpExplorer` | `lib/views/insights/cdp_explorer/cdp_explorer_insights.dart` | Tools |
| `positionSimulator` | `lib/views/insights/position_simulator/position_simulator_insights.dart` | Tools |

---

## Architecture

```
Widget (StatelessWidget / StatefulWidget)
  └─ AsyncBuilder<T>(fetcher: () => sl<XRepository>().getX(), builder: (data) => ...)
        ↓
Repository (lib/repositories/)  — TTL cache, plain Dart class
  └─ XService.fetchX()  →  Future<T>
        ↓
Service (lib/api/indigo_api/services/)  — extends IndigoApi
        ↓
IndigoApi base client  →  HTTP + JSON unwrap
```

`lib/service_locator.dart` — registers all services and repositories as lazy singletons.  
Called in `main()` before `runApp`.

**Adding a new data source:**
1. Create a service in `lib/api/indigo_api/services/`
2. Create a repository in `lib/repositories/` (TTL cache, inject service via constructor)
3. Register both in `lib/service_locator.dart`
4. Consume with `AsyncBuilder(fetcher: () => sl<XRepository>().getX(), ...)`

### TTL Reference

| Repository | TTL |
|---|---|
| `IndyPriceRepository`, `AssetPriceRepository` | 2 min |
| `AssetStatusRepository`, `CdpRepository`, `StabilityPool*Repository`, `DexYieldRepository` | 5 min |
| `LiquidationRepository`, `RedemptionRepository`, `StakeHistoryRepository` | 10 min |
| `IndigoAssetRepository` | 30 min |
| `SolvencyRepository`, `StrategyRepository`, `ProtocolDashboardRepository` (composed) | 5 min |

---

## Data Layer

- Base client: `lib/api/indigo_api/indigo_api.dart`
  - `baseUrl = https://analytics.indigoprotocol.io`
  - `getAll<T>(endpoint, fromJson)` — unwraps the `data` key when present
  - `get<T>(endpoint, fromJson)` — raw JSON object
- Services: `lib/api/indigo_api/services/` — each extends `IndigoApi`
- Repositories: `lib/repositories/` — TTL caching, constructor-injected services

---

## Active Endpoints

> **Canonical reference for endpoint changes:** [github.com/IndigoProtocol/indigo-mcp](https://github.com/IndigoProtocol/indigo-mcp)  
> Check `src/utils/indexer-client.ts` (base URL) and all `client.get/post` calls under `src/tools/` before assuming an endpoint is valid or broken.

| Service | Endpoint | Notes |
|---|---|---|
| `asset_price_service.dart` | `GET /api/asset-prices` | Price in lovelace |
| `asset_status_service.dart` | `GET /api/assets/analytics` | Per-asset market metrics |
| `cdp_service.dart` | `GET /api/cdps` | Open CDPs |
| `cdp_service.dart` | `GET /api/asset-interest-rates` | Rate in micro units |
| `dex_yield_service.dart` | `GET /api/yields` | DEX LP yields |
| `indigo_asset_service.dart` | `GET /api/assets` | iAsset config (rmr, ratios) |
| `indy_service.dart` | `GET /api/indy-price` | INDY price in ADA and USD |
| `liquidation_service.dart` | `GET /api/liquidations` | Historical liquidation events |
| `redemption_service.dart` | `GET /api/redemptions/list?page=1&perPage=1000000000&filterBy={asset}` | Paginated redemptions |
| `stability_pool_account_service.dart` | `GET /api/stability-pools-accounts` | Per-account SP snapshots |
| `stability_pool_service.dart` | `GET /api/stability-pools` | SP state per asset |
| `stake_history_service.dart` | `GET /api/staking-manager/history?page=1&perPage=1000000000` | `{data: [{s, tS, t}]}` — `t` is Unix timestamp, `tS` is lovelace |

---

## Conventions

```dart
// Standard async widget pattern
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AsyncBuilder(
      fetcher: () => sl<XRepository>().getX(),
      builder: (data) => ...,
      errorBuilder: (error, retry) => Text('Error: $error'),
    );
  }
}
```

| Utility | File |
|---|---|
| Async data loader | `lib/utils/async_builder.dart` — `AsyncBuilder(fetcher, builder, errorBuilder?)` |
| TTL cache wrapper | `lib/utils/cached_result.dart` — `CachedResult<T>(value)` |
| Multi-asset tab wrapper | `lib/widgets/indigo_asset_tabs.dart` — `IndigoAssetTabs(builder)` |
| Info card row | `lib/widgets/scrollable_information_cards.dart` — `ScrollableInformationCards(builder)` |
| Number formatting | `lib/utils/formatters.dart` — `numberFormatter(amount, decimals)` |
| Loading spinner | `lib/utils/loader.dart` — `const Loader()` |
| Page heading | `lib/utils/page_title.dart` — `PageTitle(title: '...')` |
| Colors | `lib/theme/color_scheme.dart` |
| Gradients | `lib/theme/gradients.dart` |

iAsset list (iUSD, iBTC, iETH, iSOL) is fetched at runtime via `IndigoAssetRepository` (`GET /api/assets`). Use `sl<IndigoAssetRepository>().getAssets()` wherever asset iteration is needed rather than hardcoding.

---

## Commits & PRs

**Never commit directly to `main`.** Always work on a feature branch and open a PR.

Always use **Conventional Commits**: `type(scope): description`

Common types: `feat`, `fix`, `chore`, `refactor`, `docs`, `style`, `test`  
Scope is optional but encouraged (e.g. `feat(staking)`, `fix(api)`, `chore(deps)`).

- **PR titles** must also follow Conventional Commits — the title becomes the final squash commit message on `main`.
- This repo uses **squash merge** — keep individual branch commits descriptive but the PR title is what matters.

---

## Build

```sh
flutter pub get
flutter run
```

All repositories are hand-written with explicit TTL caching. No code generation.
