class Yield {
  final String asset;
  final double apr;

  Yield({required this.asset, required this.apr});

  factory Yield.fromJson(Map<String, dynamic> json) {
    return Yield(asset: json['asset'], apr: json['apr'].toDouble());
  }

  Map<String, dynamic> toJson() {
    return {'asset': asset, 'apr': apr};
  }
}
