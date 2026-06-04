class CollateralPair {
  final String collateralAsset; // empty = ADA
  final double liquidationRatioPercent;
  final double maintenanceRatioPercent;
  final double redemptionRatioPercent;
  final double interestRate;

  CollateralPair({
    required this.collateralAsset,
    required this.liquidationRatioPercent,
    required this.maintenanceRatioPercent,
    required this.redemptionRatioPercent,
    required this.interestRate,
  });

  factory CollateralPair.fromJson(Map<String, dynamic> json) => CollateralPair(
    collateralAsset: (json['collateralAsset'] as String?) ?? '',
    liquidationRatioPercent:
        (json['liquidationRatioPercent'] as num?)?.toDouble() ?? 110.0,
    maintenanceRatioPercent:
        (json['maintenanceRatioPercent'] as num?)?.toDouble() ?? 115.0,
    redemptionRatioPercent:
        (json['redemptionRatioPercent'] as num?)?.toDouble() ?? 150.0,
    interestRate:
        ((json['interest'] as Map<String, dynamic>?)?['rate'] as num?)
            ?.toDouble() ??
        0.0,
  );
}
