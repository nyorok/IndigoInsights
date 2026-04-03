# IndigoInsights — Agent Context

Flutter analytics dashboard for Indigo Protocol (Cardano DeFi). Read-only; no wallet or write operations. Supports iUSD, iBTC, iETH, iSOL.

---

## Tech Stack

- Flutter >=3.41.5 / Dart SDK ^3.11.0
- State: `hooks_riverpod` v3 + `flutter_hooks` — **all widgets are `HookConsumerWidget`**
- Charts: `fl_chart`
- HTTP: `package:http`
- Font: Quicksand; theme: Material 3 (`lib/theme/`)

---

## Navigation

`lib/sidebar.dart` — `SidebarMenu` enum is the single source of truth for pages.  
`lib/main.dart` — `switch(SidebarMenu.values[selectedMenuItem.value])` renders the active page.

**To add a page:** add an enum value to `SidebarMenu` → add a `getListTile` call in `Sidebar.build` → add an import + switch case in `main.dart`.

Current pages:

| Enum value | View file |
|---|---|
| `strategy` | `lib/views/insights/strategy/strategy_insights.dart` |
| `liquidation` | `lib/views/insights/liquidation/liquidation_insights.dart` |
| `redemption` | `lib/views/insights/redemption/redemption_insights.dart` |
| `indyStaking` | `lib/views/insights/indy_staking/indy_staking_insights.dart` |
| `stabilityPool` | `lib/views/insights/stability_pool/stability_pool_insights.dart` |
| `stabilityPoolAccount` | `lib/views/insights/stability_pool_account/stability_pool_account_insights.dart` |

---

## Data Layer

Flow: **Service → Provider → View** (views never import services directly).

- Base client: `lib/api/indigo_api/indigo_api.dart`
  - `baseUrl = https://analytics.indigoprotocol.io`
  - `getAll<T>(endpoint, fromJson)` — unwraps the `data` key when present
  - `get<T>(endpoint, fromJson)` — raw JSON object
- Services: `lib/api/indigo_api/services/` — each extends `IndigoApi`
- Providers: `lib/providers/` — plain `FutureProvider` / `FutureProvider.family`

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
// Standard widget pattern
class MyWidget extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(someProvider).when(
      data: (data) => ...,
      loading: () => const Loader(),
      error: (e, _) => Text('Error: $e'),
    );
  }
}
```

| Utility | File |
|---|---|
| Multi-asset tab wrapper | `lib/widgets/indigo_asset_tabs.dart` — `IndigoAssetTabs(builder)` |
| Info card row | `lib/widgets/scrollable_information_cards.dart` — `ScrollableInformationCards(builder)` |
| Number formatting | `lib/utils/formatters.dart` — `numberFormatter(amount, decimals)` |
| Loading spinner | `lib/utils/loader.dart` — `const Loader()` |
| Page heading | `lib/utils/page_title.dart` — `PageTitle(title: '...')` |
| Colors | `lib/theme/color_scheme.dart` |
| Gradients | `lib/theme/gradients.dart` |

iAsset list (iUSD, iBTC, iETH, iSOL) is fetched at runtime via `indigoAssetsProvider` (`GET /api/assets`). Use this provider wherever asset iteration is needed rather than hardcoding.

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

All providers are hand-written `FutureProvider` / `FutureProvider.family` / `Provider.family`. No code generation.
