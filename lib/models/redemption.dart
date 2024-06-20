class Redemption {
  final int id;
  final int slot;
  final String txHash;
  final String asset;
  final double redeemedAmount;
  final double lovelacesReturned;
  final double processingFeeLovelaces;
  final double reimbursementFeeLovelaces;
  final String oraclePrice;
  final String adaPrice;
  final DateTime createdAt;
  final DateTime updatedAt;

  Redemption({
    required this.id,
    required this.slot,
    required this.txHash,
    required this.asset,
    required this.redeemedAmount,
    required this.lovelacesReturned,
    required this.processingFeeLovelaces,
    required this.reimbursementFeeLovelaces,
    required this.oraclePrice,
    required this.adaPrice,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Redemption.fromJson(Map<String, dynamic> json) {
    return Redemption(
      id: json['id'],
      slot: json['slot'],
      txHash: json['tx_hash'] ?? "",
      asset: json['asset'] ?? "",
      redeemedAmount: json['redeemed_amount'] / 1e6,
      lovelacesReturned: json['lovelaces_returned'] / 1e6,
      processingFeeLovelaces: json['processing_fee_lovelaces'] / 1e6,
      reimbursementFeeLovelaces: json['reimbursement_fee_lovelaces'] / 1e6,
      oraclePrice: json['oracle_price'] ?? "",
      adaPrice: json['ada_price'] ?? "",
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
