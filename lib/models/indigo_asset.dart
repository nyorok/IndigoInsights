class IndigoAsset {
  final String asset;
  final DateTime createdAt;
  final double? delistPrice;
  final String hash;
  final String? oracleNftCs;
  final String? oracleNftTn;
  final String outputHash;
  final int outputIndex;
  final int slot;
  final DateTime updatedAt;

  // V3: these ratios live on the collateral pair, not the iAsset; null until a
  // collateral endpoint is published.
  final double? rmr;
  final double? maintenanceRatio;
  final double? liquidationRatio;

  // V3: plain percentages (e.g. 0.1 = 0.1%), not micro-units.
  final double debtMintingFee;
  final double? liquidationProcessingFee;
  final double? stabilityPoolWithdrawalFee;
  final double? redemptionProcessingFee;
  final double? redemptionReimbursementFee;

  IndigoAsset({
    required this.asset,
    required this.createdAt,
    this.delistPrice,
    required this.hash,
    this.oracleNftCs,
    this.oracleNftTn,
    required this.outputHash,
    required this.outputIndex,
    required this.slot,
    required this.updatedAt,
    this.rmr,
    this.maintenanceRatio,
    this.liquidationRatio,
    required this.debtMintingFee,
    this.liquidationProcessingFee,
    this.stabilityPoolWithdrawalFee,
    this.redemptionProcessingFee,
    this.redemptionReimbursementFee,
  });

  factory IndigoAsset.fromJson(Map<String, dynamic> json) {
    double? _pct(String key) {
      final v = json[key];
      if (v == null) return null;
      return (v as num).toDouble();
    }

    return IndigoAsset(
      asset: json['asset'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      delistPrice: json['delist_price'] != null
          ? double.parse(json['delist_price'] as String)
          : null,
      hash: json['hash'] as String,
      oracleNftCs: json['oracle_nft_cs'] as String?,
      oracleNftTn: json['oracle_nft_tn'] as String?,
      outputHash: json['output_hash'] as String,
      outputIndex: json['output_index'] as int,
      slot: json['slot'] as int,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      rmr: _pct('redemption_ratio_percentage'),
      maintenanceRatio: _pct('maintenance_ratio_percentage'),
      liquidationRatio: _pct('liquidation_ratio_percentage'),
      debtMintingFee: _pct('debt_minting_fee_percentage') ?? 0.0,
      liquidationProcessingFee: _pct('liquidation_processing_fee_percentage'),
      stabilityPoolWithdrawalFee: _pct('stability_pool_withdrawal_fee_percentage'),
      redemptionProcessingFee: _pct('redemption_processing_fee_percentage'),
      redemptionReimbursementFee: _pct('redemption_reimbursement_percentage'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'asset': asset,
      'createdAt': createdAt.toIso8601String(),
      'delist_price': delistPrice,
      'hash': hash,
      'oracle_nft_cs': oracleNftCs,
      'oracle_nft_tn': oracleNftTn,
      'output_hash': outputHash,
      'output_index': outputIndex,
      'slot': slot,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
