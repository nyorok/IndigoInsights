class AssetStatus {
  final String asset;

  /// USD market cap (= [totalSupply] × iAsset USD price). Includes iAssets
  /// minted through the PSM, so this is larger than the CDP debt.
  final double marketCap;

  /// ⚠️ Broken upstream: the API computes this as
  /// `totalValueLocked / marketCap * 100`, i.e. a raw token count divided by a
  /// USD value, which reads ~5x too high. Use `LoanAnalytics` instead.
  final double totalCollateralRatio;

  /// Circulating supply of the iAsset, including PSM-minted amounts (iUSD can
  /// be minted 1:1 against USDM/USDCx/USDA without a CDP). For CDP debt, sum
  /// `Cdp.mintedAmount` instead.
  final double totalSupply;

  /// ⚠️ Broken upstream: a unit-blind sum of collateral token amounts
  /// (ADA + NIGHT + USDCx added as if 1:1), not a USD or ADA value. Was
  /// equivalent to ADA in V2 when ADA was the only collateral. Use
  /// `LoanAnalytics.collateralUsdByAsset` instead.
  final double totalValueLocked;

  AssetStatus({
    required this.asset,
    required this.marketCap,
    required this.totalCollateralRatio,
    required this.totalSupply,
    required this.totalValueLocked,
  });

  /// USD price of one unit of the iAsset, derived from the same snapshot as
  /// [marketCap] so the two stay internally consistent.
  double get usdPrice => totalSupply > 0 ? marketCap / totalSupply : 0.0;

  factory AssetStatus.fromJson(Map<String, dynamic> json) {
    return AssetStatus(
      asset: json['asset'] as String,
      marketCap: (json['marketCap'] as num).toDouble(),
      totalCollateralRatio: (json['totalCollateralRatio'] as num).toDouble(),
      totalSupply: (json['totalSupply'] as num).toDouble(),
      totalValueLocked: (json['totalValueLocked'] as num).toDouble(),
    );
  }
}
