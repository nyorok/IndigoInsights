// https://github.com/IndigoProtocol/indigo-smart-contracts/blob/main/src/Indigo/Contracts/StabilityPool/Common.hs#L169C1-L191C4

BigInt conversionValue = BigInt.from(10).pow(24);

class StabilityPoolAccount {
  final String asset;
  final String owner;

  double get totalAmount => snapshotD / conversionValue;

  final BigInt snapshotD;
  final BigInt snapshotP;
  final BigInt? snapshotS; // null in V3 (moved to per-collateral asset_states)
  final int snapshotEpoch;
  final int snapshotScale;

  StabilityPoolAccount({
    required this.asset,
    required this.owner,
    required this.snapshotD,
    required this.snapshotP,
    this.snapshotS,
    required this.snapshotEpoch,
    required this.snapshotScale,
  });

  factory StabilityPoolAccount.fromJson(Map<String, dynamic> json) {
    return StabilityPoolAccount(
      asset: json['asset'] as String,
      owner: json['owner'] as String,
      snapshotD: BigInt.parse(json['snapshotD'] as String),
      snapshotP: BigInt.parse(json['snapshotP'] as String),
      snapshotS: json['snapshotS'] != null
          ? BigInt.parse(json['snapshotS'] as String)
          : null,
      snapshotEpoch: json['snapshotEpoch'] as int,
      snapshotScale: json['snapshotScale'] as int,
    );
  }
}
