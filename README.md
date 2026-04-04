# Indigo Insights

[![Deploy Web App to GitHub Pages](https://github.com/nyorok/IndigoInsights/actions/workflows/deploy.yml/badge.svg?branch=main)](https://github.com/nyorok/IndigoInsights/actions/workflows/deploy.yml)
[![Flutter](https://img.shields.io/badge/Flutter-3.41.5-blue?logo=flutter)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-purple)](LICENSE)

> Protocol analytics dashboard for the [Indigo Protocol](https://indigoprotocol.io) community, built with Flutter — available as a **web app**, **Android APK**, and **PWA**.

**[🌐 Open Web App](https://nyorok.github.io/IndigoInsights)** &nbsp;|&nbsp; **[📦 Download APK](https://github.com/nyorok/IndigoInsights/tree/main/release)**

---

## Features

### 📊 Protocol Dashboard
Real-time overview of Total Value Locked, iAsset market caps, active CDPs, and INDY price with a 24-hour activity feed.

### 🔍 CDP Explorer
Browse and filter all Collateralised Debt Positions by size tier (Whale › Shrimp). Visualise CR distribution across the protocol with a live data table.

### ⚡ Liquidation Analytics
Cumulative liquidation chart, size distribution, frequency analysis, and historical liquidation price levels.

### 🔄 Redemption Analytics
Redeemable amounts across RMR thresholds, fee breakdown, and average redemption size over time.

### 🏦 Stability Pool
Solvency chart, analytics card, liquidation scenario simulator (drag ADA price to stress-test), top endangered CDPs with copy-to-clipboard, and historical liquidation price statistics.

### 💰 INDY Staking
Governance rewards, staking velocity, staking history, and KPI strip with delta tracking.

### 📈 Yield Optimizer
Side-by-side yield comparison table across strategies with top yield strategies highlighted.

### 🎯 Strategy Guide
Five detailed strategies (ADA Leverage above RMR/MR, ADA Double Leverage, ADA Farming Stability/Stable Pool) with risk labels, expandable descriptions, and step-by-step content.

### 🧮 Position Simulator
Enter collateral and minted amounts to get: current CR, liquidation/maintenance/RMR prices, drop-to-liquidation %, safety gauge, price scenario table, and interest cost projection.

### 🏛 SP Account
Stability pool account distribution and unclaimed rewards visualised as pie charts.

---

## Tech Stack

| Layer | Library |
|---|---|
| Framework | Flutter 3.41.5 / Dart 3.x |
| Routing | `go_router` — URL-based navigation with tab-level deep links (e.g. `/#/cdp-explorer?tab=iUSD`) |
| State / DI | `get_it` — service locator + repository pattern |
| Charts | `fl_chart` |
| Animations | `flutter_animate` |
| Fonts | `google_fonts` — Outfit + JetBrains Mono |
| HTTP | `http` |
| Theme | Custom `ThemeExtension<T>` design token system (`AppColorScheme`, `AppTextStyles`) |

---

## Architecture

```
lib/
├── api/               # Raw API clients
├── models/            # Data models (Cdp, Liquidation, StabilityPool, …)
├── repositories/      # Cached data layer (one repo per domain)
├── services/          # Cross-cutting services (PWA install)
├── theme/             # Design tokens — color scheme, text styles, gradients
│   └── schemes/       # Per-theme overrides (dark, future: light/blue)
├── router.dart        # go_router config — all routes & tab params
├── sidebar.dart       # Navigation sidebar + donation footer
├── service_locator.dart
├── views/insights/    # One folder per page
│   ├── dashboard/
│   ├── cdp_explorer/
│   ├── liquidation/
│   ├── redemption/
│   ├── stability_pool/
│   ├── stability_pool_account/
│   ├── indy_staking/
│   ├── yield_optimizer/
│   ├── strategy/
│   └── position_simulator/
└── widgets/           # Reusable ii_* widget library
    ├── ii_card.dart
    ├── ii_top_bar.dart
    ├── ii_tab_bar.dart
    ├── ii_kpi_strip.dart
    ├── ii_asset_tabs.dart
    ├── ii_disclaimer.dart
    ├── pwa_install_banner.dart
    └── …
```

---

## Responsive Design

The app uses a **700 px breakpoint** throughout:

| Breakpoint | Layout |
|---|---|
| ≥ 700 px (desktop) | Persistent sidebar · side-by-side cards · horizontal KPI strip |
| < 700 px (mobile) | Hamburger drawer · stacked cards · vertical KPI strip · compact tabs |

PWA install is surfaced as an **"Install App"** button in the top bar on mobile, and as a slide-up banner on desktop.

---

## URL Routing

Every page and tab is directly addressable:

| Route | Page |
|---|---|
| `/#/dashboard` | Protocol Dashboard |
| `/#/cdp-explorer?tab=iUSD` | CDP Explorer — iUSD tab |
| `/#/liquidation?tab=iBTC` | Liquidation — iBTC tab |
| `/#/redemption?tab=iETH` | Redemption — iETH tab |
| `/#/stability-pool?tab=iSOL` | Stability Pool — iSOL tab |
| `/#/indy-staking` | INDY Staking |
| `/#/yield-optimizer` | Yield Optimizer |
| `/#/strategy` | Strategy Guide |
| `/#/position-simulator` | Position Simulator |
| `/#/sp-account` | SP Account |

---

## Getting Started

### Prerequisites
- Flutter `3.41.5` (or compatible `>=3.29.0`)
- Dart `>=3.11.0`

### Run locally

```bash
git clone https://github.com/nyorok/IndigoInsights.git
cd IndigoInsights
flutter pub get
flutter run -d chrome
```

### Build for web

```bash
flutter build web --release --base-href /IndigoInsights/
```

### Build APK

```bash
flutter build apk --release
```

---

## Deployment

GitHub Actions automatically deploys to GitHub Pages on every push to `main`.  
See [`.github/workflows/deploy.yml`](.github/workflows/deploy.yml) for the full pipeline.

---

## Support Development

If you find Indigo Insights useful, consider supporting the project with a small ADA donation:

```
addr1qxjalxzyptawry6aglve6awl5dw9athelw66zta3kumgf07my5zpph5fyjj8y2g8e4w2y7hqhksprd7l28h5kppaspxsfenzek
```

---

## Disclaimer

This application is for **educational and informational purposes only** and does not constitute financial advice. Always do your own research and consult a qualified financial professional before making investment decisions.

---

*Built with ❤️ for the Indigo community by PWG.*
