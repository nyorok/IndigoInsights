/// Authoritative protocol aggregates from `/api/v3/analytics/loans`.
///
/// Use these instead of `AssetStatus.totalValueLocked` / `totalCollateralRatio`,
/// which are unit-blind (see [AssetStatus] docs).
class LoanAnalytics {
  /// Number of open CDPs.
  final int totalLoans;

  /// USD value of all CDP collateral (ADA + NIGHT + USDCx converted).
  final double collateralValueUsd;

  /// USD value of all CDP debt. Excludes PSM-minted iAssets, which have no CDP.
  final double debtValueUsd;

  /// Per-iAsset CDP collateral value in USD.
  final Map<String, double> collateralUsdByAsset;

  const LoanAnalytics({
    required this.totalLoans,
    required this.collateralValueUsd,
    required this.debtValueUsd,
    required this.collateralUsdByAsset,
  });

  /// System collateral ratio in percent (collateral / debt).
  double get systemCollateralRatio =>
      debtValueUsd > 0 ? collateralValueUsd / debtValueUsd * 100 : 0;

  factory LoanAnalytics.fromJson(Map<String, dynamic> json) {
    final assets = (json['assets'] as Map<String, dynamic>?) ?? {};
    return LoanAnalytics(
      totalLoans: (json['total'] as num?)?.toInt() ?? 0,
      collateralValueUsd:
          (json['collateralValueUsd'] as num?)?.toDouble() ?? 0.0,
      debtValueUsd: (json['debtValueUsd'] as num?)?.toDouble() ?? 0.0,
      collateralUsdByAsset: {
        for (final e in assets.entries)
          e.key: ((e.value as Map<String, dynamic>)['collateralValueUsd']
                      as num?)
                  ?.toDouble() ??
              0.0,
      },
    );
  }
}

/// Latest point of the `/api/v3/analytics/tvl` time series (USD).
class TvlAnalytics {
  /// Value locked in the protocol itself (CDP collateral, PSM reserves, …).
  final double protocolUsd;

  /// Value of staked INDY.
  final double stakingUsd;

  const TvlAnalytics({required this.protocolUsd, required this.stakingUsd});

  /// What the official app shows as the "All" TVL figure.
  double get totalUsd => protocolUsd + stakingUsd;

  factory TvlAnalytics.fromJson(Map<String, dynamic> json) {
    double latest(String key) {
      final series = json[key] as List<dynamic>?;
      if (series == null || series.isEmpty) return 0.0;
      final last = series.last as Map<String, dynamic>;
      return (last['value'] as num?)?.toDouble() ?? 0.0;
    }

    return TvlAnalytics(
      protocolUsd: latest('usd'),
      stakingUsd: latest('stakingUsd'),
    );
  }
}
