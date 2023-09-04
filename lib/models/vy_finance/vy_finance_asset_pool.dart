class VyFinanceAssetPool {
  final String assetA;
  final String assetB;
  final double quantityA;
  final double quantityB;

  VyFinanceAssetPool({
    required this.assetA,
    required this.assetB,
    required this.quantityA,
    required this.quantityB,
  });

  factory VyFinanceAssetPool.fromJson(Map<String, dynamic> json) {
    return VyFinanceAssetPool(
      assetA: (json['pair'] as String).split('/')[0],
      assetB: (json['pair'] as String).split('/')[1],
      quantityA: json['tokenAQuantity'] / 1000000,
      quantityB: json['tokenBQuantity'] / 1000000,
    );
  }
}
