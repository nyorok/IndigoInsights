class Liquidation {
  final double adaPrice;
  final String asset;
  final double collateralAbsorbed;
  final DateTime createdAt;
  final double iAssetBurned;
  final int id;
  final double oraclePrice;
  final String outputHash;
  final int outputIndex;
  final int slot;
  final DateTime updatedAt;

  Liquidation(
      {required this.adaPrice,
      required this.asset,
      required this.collateralAbsorbed,
      required this.createdAt,
      required this.iAssetBurned,
      required this.id,
      required this.oraclePrice,
      required this.outputHash,
      required this.outputIndex,
      required this.slot,
      required this.updatedAt});

  factory Liquidation.fromJson(Map<String, dynamic> json) {
    return Liquidation(
      adaPrice: double.parse(json['ada_price'] as String),
      asset: json['asset'] as String,
      collateralAbsorbed: (json['collateral_absorbed'] as num) / 1000000,
      createdAt: DateTime.parse(json['created_at'] as String),
      iAssetBurned: (json['iasset_burned'] as num) / 1000000,
      id: json['id'] as int,
      oraclePrice: double.parse(json['oracle_price'] as String),
      outputHash: json['output_hash'] as String,
      outputIndex: json['output_index'] as int,
      slot: json['slot'] as int,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ada_price': adaPrice,
      'asset': asset,
      'collateral_absorbed': collateralAbsorbed,
      'created_at': createdAt,
      'iasset_burned': iAssetBurned,
      'id': id,
      'oracle_price': oraclePrice,
      'output_hash': outputHash,
      'output_index': outputIndex,
      'slot': slot,
      'updated_at': updatedAt,
    };
  }
}
