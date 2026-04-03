class AssetPrice {
  final String asset;
  final double price;

  AssetPrice({required this.asset, required this.price});

  factory AssetPrice.fromJson(Map<String, dynamic> json) {
    return AssetPrice(asset: json['asset'] as String, price: (json['price'] as num) / 1000000);
  }

  Map<String, dynamic> toJson() {
    return {'asset': asset, 'price': price};
  }
}
