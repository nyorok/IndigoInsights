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
      adaPrice: double.parse(json['ada_price']),
      asset: json['asset'],
      collateralAbsorbed: json['collateral_absorbed'] / 1000000,
      createdAt: DateTime.parse(json['created_at']),
      iAssetBurned: json['iasset_burned'] / 1000000,
      id: json['id'],
      oraclePrice: double.parse(json['oracle_price']),
      outputHash: json['output_hash'],
      outputIndex: json['output_index'],
      slot: json['slot'],
      updatedAt: DateTime.parse(json['updated_at']),
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
