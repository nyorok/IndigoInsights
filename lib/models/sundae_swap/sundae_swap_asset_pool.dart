class SundaeSwapAssetPool {
  final String assetA;
  final String assetB;
  final double quantityA;
  final double quantityB;

  SundaeSwapAssetPool({
    required this.assetA,
    required this.assetB,
    required this.quantityA,
    required this.quantityB,
  });

  factory SundaeSwapAssetPool.fromJson(Map<String, dynamic> json) {
    return SundaeSwapAssetPool(
      assetA: (json['name'] as String).split('/')[0],
      assetB: (json['name'] as String).split('/')[1],
      quantityA: double.parse(json['quantityA']) / 1000000,
      quantityB: double.parse(json['quantityB']) / 1000000,
    );
  }
}
