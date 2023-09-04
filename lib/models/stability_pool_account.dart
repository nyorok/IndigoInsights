// Documentation about each property
// https://github.com/IndigoProtocol/indigo-smart-contracts/blob/main/src/Indigo/Contracts/StabilityPool/Common.hs#L169C1-L191C4

BigInt conversionValue = BigInt.from(10).pow(24);

class StabilityPoolAccount {
  final String asset;
  final String owner;
  double get totalAmount =>
      snapshotD / conversionValue; // ToDo: Remove to use snapshotD

  final BigInt snapshotD;
  final BigInt snapshotP;
  final BigInt snapshotS;
  final int snapshotEpoch;
  final int snapshotScale;

  StabilityPoolAccount(
      {required this.asset,
      required this.owner,
      required this.snapshotD,
      required this.snapshotP,
      required this.snapshotS,
      required this.snapshotEpoch,
      required this.snapshotScale});

  factory StabilityPoolAccount.fromJson(Map<String, dynamic> json) {
    return StabilityPoolAccount(
      asset: json['asset'],
      owner: json['owner'],
      snapshotD: BigInt.parse(json['snapshotD']),
      snapshotP: BigInt.parse(json['snapshotP']),
      snapshotS: BigInt.parse(json['snapshotS']),
      snapshotEpoch: json['snapshotEpoch'],
      snapshotScale: json['snapshotScale'],
    );
  }
}
