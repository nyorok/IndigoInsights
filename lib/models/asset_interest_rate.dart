class AssetInterestRate {
  final String asset;
  final String collateralAsset; // V3: per-collateral interest oracle
  final double interestRate;
  final int slot;

  AssetInterestRate({
    required this.asset,
    this.collateralAsset = '',
    required this.interestRate,
    required this.slot,
  });

  factory AssetInterestRate.fromJson(Map<String, dynamic> json) {
    return AssetInterestRate(
      asset: json['asset'] as String,
      collateralAsset: (json['collateral_asset'] as String?) ?? '',
      interestRate: ((json['interest_rate'] as int?) ?? 0) / 1000000,
      slot: json['slot'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'asset': asset,
      'collateral_asset': collateralAsset,
      'interestRate': interestRate,
    };
  }
}
