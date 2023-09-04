class VyFinanceAssetPoolInformation {
  final String assetA;
  final String assetB;
  final String symbolA;
  final String symbolB;

  VyFinanceAssetPoolInformation({
    required this.assetA,
    required this.assetB,
    required this.symbolA,
    required this.symbolB,
  });

  factory VyFinanceAssetPoolInformation.fromJson(Map<String, dynamic> json) {
    return VyFinanceAssetPoolInformation(
      assetA: (json['pair'] as String).split('/')[0],
      assetB: (json['pair'] as String).split('/')[1],
      symbolA: (json['unitsPair'] as String).split('/')[0],
      symbolB: (json['unitsPair'] as String).split('/')[1],
    );
  }
}
