class IndigoAsset {
  final String asset;
  final DateTime createdAt;
  final double? delistPrice;
  final String hash;
  final String oracleNftCs;
  final String oracleNftTn;
  final String outputHash;
  final int outputIndex;
  final int slot;
  final DateTime updatedAt;

  IndigoAsset({
    required this.asset,
    required this.createdAt,
    this.delistPrice,
    required this.hash,
    required this.oracleNftCs,
    required this.oracleNftTn,
    required this.outputHash,
    required this.outputIndex,
    required this.slot,
    required this.updatedAt,
  });

  factory IndigoAsset.fromJson(Map<String, dynamic> json) {
    return IndigoAsset(
      asset: json['asset'],
      createdAt: DateTime.parse(json['created_at']),
      delistPrice: json['delist_price'] != null
          ? double.parse(json['delist_price'])
          : null,
      hash: json['hash'],
      oracleNftCs: json['oracle_nft_cs'],
      oracleNftTn: json['oracle_nft_tn'],
      outputHash: json['output_hash'],
      outputIndex: json['output_index'],
      slot: json['slot'],
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'asset': asset,
      'createdAt': createdAt,
      'delist_price': delistPrice,
      'hash': hash,
      'oracle_nft_cs': oracleNftCs,
      'oracle_nft_tn': oracleNftCs,
      'output_hash': outputHash,
      'output_index': outputIndex,
      'slot': slot,
      'updated_at': updatedAt,
    };
  }
}
