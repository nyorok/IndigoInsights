class AssetStatus {
  final String asset;
  final double marketCap;
  final double totalCollateralRatio;
  final double totalSupply;
  final double totalValueLocked;

  AssetStatus({
    required this.asset,
    required this.marketCap,
    required this.totalCollateralRatio,
    required this.totalSupply,
    required this.totalValueLocked,
  });

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
