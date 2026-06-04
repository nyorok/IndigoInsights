class Liquidation {
  // V3: renamed from ada_price → collateral_asset_usd_price; now a num (not string)
  final double collateralUsdPrice;
  final String asset;
  final String collateralAsset;
  final double collateralAbsorbed;
  final DateTime createdAt;
  final double iAssetBurned;
  final int id;
  final double? oraclePrice; // absent on recent V3 liquidations
  final String outputHash;
  final int outputIndex;
  final int slot;
  final DateTime updatedAt;

  Liquidation({
    required this.collateralUsdPrice,
    required this.asset,
    this.collateralAsset = '',
    required this.collateralAbsorbed,
    required this.createdAt,
    required this.iAssetBurned,
    required this.id,
    this.oraclePrice,
    required this.outputHash,
    required this.outputIndex,
    required this.slot,
    required this.updatedAt,
  });

  // Back-compat getter used by existing callers expecting ada_price
  double get adaPrice => collateralUsdPrice;

  factory Liquidation.fromJson(Map<String, dynamic> json) {
    double parseUsdPrice() {
      final v3 = json['collateral_asset_usd_price'];
      if (v3 != null) return (v3 as num).toDouble();
      // V2 fallback
      final v2 = json['ada_price'];
      if (v2 != null) return double.parse(v2 as String);
      return 0.0;
    }

    double? parseOraclePrice() {
      final v = json['oracle_price'];
      if (v == null) return null;
      return double.parse(v as String);
    }

    return Liquidation(
      collateralUsdPrice: parseUsdPrice(),
      asset: json['asset'] as String,
      collateralAsset: (json['collateral_asset'] as String?) ?? '',
      collateralAbsorbed: (json['collateral_absorbed'] as num) / 1000000,
      createdAt: DateTime.parse(json['created_at'] as String),
      iAssetBurned: (json['iasset_burned'] as num) / 1000000,
      id: json['id'] as int,
      oraclePrice: parseOraclePrice(),
      outputHash: (json['output_hash'] as String?) ?? '',
      outputIndex: (json['output_index'] as int?) ?? 0,
      slot: json['slot'] as int,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'collateral_asset_usd_price': collateralUsdPrice,
      'asset': asset,
      'collateral_asset': collateralAsset,
      'collateral_absorbed': collateralAbsorbed,
      'created_at': createdAt.toIso8601String(),
      'iasset_burned': iAssetBurned,
      'id': id,
      'oracle_price': oraclePrice,
      'output_hash': outputHash,
      'output_index': outputIndex,
      'slot': slot,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
