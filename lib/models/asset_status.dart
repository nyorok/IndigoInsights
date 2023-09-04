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
      asset: json['asset'],
      marketCap: json['marketCap'],
      totalCollateralRatio: json['totalCollateralRatio'],
      totalSupply: json['totalSupply'],
      totalValueLocked: json['totalValueLocked'],
    );
  }
}
