// https://github.com/IndigoProtocol/indigo-smart-contracts/blob/main/src/Indigo/Contracts/StabilityPool/Common.hs#L169C1-L191C4

BigInt conversionValue = BigInt.from(10).pow(24);

class StabilityPoolAccount {
  final String asset;
  final String owner;

  double get totalAmount => snapshotD / conversionValue;

  final BigInt snapshotD;
  final BigInt snapshotP;
  final BigInt? snapshotS; // V2 only; V3 moved to per-collateral [assetSums]
  final int snapshotEpoch;
  final int snapshotScale;

  /// V3: the account's S snapshot per collateral asset ('' = ADA), from
  /// `asset_sums`. Pairs with StabilityPool.assetStates to compute unclaimed
  /// rewards per collateral token.
  final Map<String, BigInt> assetSums;

  StabilityPoolAccount({
    required this.asset,
    required this.owner,
    required this.snapshotD,
    required this.snapshotP,
    this.snapshotS,
    required this.snapshotEpoch,
    required this.snapshotScale,
    this.assetSums = const {},
  });

  factory StabilityPoolAccount.fromJson(Map<String, dynamic> json) {
    final Map<String, BigInt> assetSums = {};
    final rawSums = json['asset_sums'];
    if (rawSums is List) {
      for (final entry in rawSums) {
        final row = entry as Map<String, dynamic>;
        assetSums[(row['asset'] as String?) ?? ''] =
            BigInt.parse(row['sumVal'] as String);
      }
    }

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
      assetSums: assetSums,
    );
  }
}
