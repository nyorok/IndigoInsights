import 'package:flutter/material.dart';
import 'package:indigo_insights/theme/app_color_scheme.dart';

// ── iAsset colour helpers ─────────────────────────────────────────────────────

Color getColorByAsset(String asset) => switch (asset) {
      'iUSD' => const Color(0xFF70D150),
      'iBTC' => const Color(0xFFFF9416),
      'iETH' => Colors.white,
      'iSOL' => const Color(0xFF9945FF),
      _ => const Color(0xFF9945FF),
    };

LinearGradient getGradientByAsset(String asset) => switch (asset) {
      'iUSD' => usdTransparentGradient,
      'iBTC' => btcTransparentGradient,
      'iETH' => ethTransparentGradient,
      'iSOL' => solTransparentGradient,
      _ => solTransparentGradient,
    };

// ── Sidebar / nav active state ────────────────────────────────────────────────

/// Purple gradient used for the active sidebar nav item and active tab chips.
const accentSelectionGradient = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [Color(0x229945FF), Color(0x159945FF)],
);

// ── Accent Panel ──────────────────────────────────────────────────────────────

/// Returns the purple gradient used for Accent Panel cards (e.g. 24h Activity).
/// Call this inside build() so it can access the theme if needed.
LinearGradient accentPanelGradient() => const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0x229945FF), Color(0x159945FF)],
    );

/// Returns a subtle tinted gradient for a given iAsset card background.
LinearGradient assetCardGradient(String asset) {
  final base = getColorByAsset(asset);
  return LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [base.withValues(alpha: 0.13), base.withValues(alpha: 0.03)],
  );
}

// ── Per-asset transparent gradients (used in charts) ─────────────────────────

final btcTransparentGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Colors.white.withValues(alpha: 0.7),
    const Color(0xFFFF9416).withValues(alpha: 0.4),
  ],
);

final usdTransparentGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Colors.white.withValues(alpha: 0.7),
    const Color(0xFF70D150).withValues(alpha: 0.4),
  ],
);

final ethTransparentGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Colors.white.withValues(alpha: 0.7),
    const Color(0xFF141414).withValues(alpha: 0.4),
  ],
);

final solTransparentGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Colors.white.withValues(alpha: 0.7),
    const Color(0xFF00FFA3).withValues(alpha: 0.7),
    const Color(0xFF9945FF).withValues(alpha: 0.6),
  ],
);

// ── Legacy gradient shims — kept for pre-refactor pages ─────────────────────
// These will be removed as each page is updated to use AppColorScheme directly.

const indigoGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFF3F01A1), Color(0xFF6200AE)],
);

const blueGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
);

const greenGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFF166534), Color(0xFF4ADE80)],
);

const greyGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFF37474F), Color(0xFF546E7A)],
);

const greenBlueGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  stops: [0, 0.5, 0.8, 1],
  colors: [
    Color(0xFF4ADE80),
    Color(0xFF1565C0),
    Color(0xFFFF6735),
    Color(0xFFFF3344),
  ],
);

/// A 4-stop gradient from safe (green) → danger (red) for solvency charts.
/// Pass stops from the [AppColorScheme] for theme consistency.
LinearGradient solvencyGradient(AppColorScheme colors) => LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      stops: const [0, 0.4, 0.7, 1],
      colors: [colors.success, colors.warning, colors.warning, colors.error],
    );
