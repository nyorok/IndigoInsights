class CdpsStats {
  final String asset;
  final double totalCollateral;
  final double totalMinted;
  final DateTime time;
  final String interval;

  CdpsStats({
    required this.asset,
    required this.totalCollateral,
    required this.totalMinted,
    required this.time,
    required this.interval,
  });

  factory CdpsStats.fromJson(Map<String, dynamic> json) {
    return CdpsStats(
      asset: json['asset'],
      totalCollateral: json['total_collateral'] / 1000000,
      totalMinted: json['total_minted'] / 1000000,
      time: DateTime.fromMillisecondsSinceEpoch(
          json['time'] * 1000), // Convert to DateTime
      interval: json['interval'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'asset': asset,
      'total_collateral': (totalCollateral * 1000000).toInt(),
      'total_minted': (totalMinted * 1000000).toInt(),
      'time':
          time.millisecondsSinceEpoch ~/ 1000, // Convert back to UNIX timestamp
      'interval': interval,
    };
  }
}
