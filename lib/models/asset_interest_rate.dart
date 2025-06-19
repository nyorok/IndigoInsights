class AssetInterestRate {
  final String asset;
  final double interestRate;
  final int slot;

  AssetInterestRate({
    required this.asset,
    required this.interestRate,
    required this.slot,
  });

  factory AssetInterestRate.fromJson(Map<String, dynamic> json) {
    return AssetInterestRate(
      asset: json['asset'],
      interestRate: (json['interest_rate'] ?? 0) / 1000000,
      slot: json['slot'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'asset': asset, 'interestRate': interestRate};
  }
}
