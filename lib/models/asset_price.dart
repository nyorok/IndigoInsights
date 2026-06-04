class AssetPrice {
  final String asset;
  final String collateralAsset;
  final double price;

  AssetPrice({required this.asset, this.collateralAsset = '', required this.price});

  factory AssetPrice.fromJson(Map<String, dynamic> json) {
    return AssetPrice(
      asset: json['asset'] as String,
      collateralAsset: (json['collateral_asset'] as String?) ?? '',
      price: double.parse(json['price'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {'asset': asset, 'collateral_asset': collateralAsset, 'price': price};
  }
}
