class Yield {
  final String asset;
  final double apr;

  Yield({required this.asset, required this.apr});

  factory Yield.fromJson(Map<String, dynamic> json) {
    return Yield(asset: json['asset'] as String, apr: (json['apr'] as num).toDouble());
  }

  Map<String, dynamic> toJson() {
    return {'asset': asset, 'apr': apr};
  }
}
