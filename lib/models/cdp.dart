class Cdp {
  final String asset;
  final double collateralAmount;
  final double mintedAmount;
  final int outputIndex;
  final String outputHash;
  final String owner;

  Cdp(
      {required this.asset,
      required this.collateralAmount,
      required this.mintedAmount,
      required this.outputIndex,
      required this.outputHash,
      required this.owner});

  factory Cdp.fromJson(Map<String, dynamic> json) {
    return Cdp(
        asset: json['asset'] as String,
        collateralAmount: (json['collateralAmount'] as num) / 1000000,
        mintedAmount: (json['mintedAmount'] as num) / 1000000,
        outputIndex: json['output_index'] as int,
        outputHash: (json['output_hash'] as String?) ?? '',
        owner: (json['owner'] as String?) ?? '');
  }

  Map<String, dynamic> toJson() {
    return {
      'asset': asset,
      'collateralAmount': collateralAmount,
      'mintedAmount': mintedAmount,
      'output_index': outputIndex,
      'output_hash': outputHash,
      'owner': owner
    };
  }
}
