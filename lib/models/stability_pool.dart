import 'dart:convert';

import 'package:indigo_insights/models/stability_pool_account.dart';

BigInt conversionValue = BigInt.from(10).pow(24);

// Documentation about each property
// https://github.com/IndigoProtocol/indigo-smart-contracts/blob/main/src/Indigo/Contracts/StabilityPool/Common.hs#L169C1-L191C4
class StabilityPool {
  final String asset;

  double get totalAmount =>
      snapshotD / conversionValue; // ToDo: Remove to use snapshotD

  final BigInt snapshotD;
  final BigInt snapshotP;
  final BigInt snapshotS;
  final int snapshotEpoch;
  final int snapshotScale;

  Map<String, BigInt> epochToScaleToSum;

  StabilityPool(
      {required this.asset,
      required this.snapshotD,
      required this.snapshotP,
      required this.snapshotS,
      required this.snapshotEpoch,
      required this.snapshotScale,
      required this.epochToScaleToSum});

  factory StabilityPool.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> rawEpochToScaleToSum =
        jsonDecode(json['epoch_to_scale_to_sum']);
    Map<String, BigInt> parsedEpochToScaleToSum = {};

    rawEpochToScaleToSum.forEach((key, value) {
      parsedEpochToScaleToSum[key] = BigInt.parse(value);
    });

    return StabilityPool(
      asset: json['asset'],
      snapshotD: BigInt.parse(json['snapshotD']),
      snapshotP: BigInt.parse(json['snapshotP']),
      snapshotS: BigInt.parse(json['snapshotS']),
      snapshotEpoch: json['snapshotEpoch'],
      snapshotScale: json['snapshotScale'],
      epochToScaleToSum: parsedEpochToScaleToSum,
    );
  }

  double getAccountBalance(StabilityPoolAccount account) {
    if (snapshotEpoch != account.snapshotEpoch) return 0;

    if (snapshotScale - account.snapshotScale > 1) return 0;

    if (snapshotScale > account.snapshotScale) {
      return (account.snapshotD * snapshotP) ~/
          (account.snapshotP * BigInt.from(10).pow(9)) /
          conversionValue;
    }

    return (account.snapshotD * snapshotP) ~/
        account.snapshotP /
        conversionValue;
  }

  double getAccountUnclaimedRewards(StabilityPoolAccount account) {
    final s1 =
        epochToScaleToSum["${account.snapshotEpoch},${account.snapshotScale}"];

    if (s1 == null) throw Exception('Could not find s1');
    final s2 = epochToScaleToSum[
            "${account.snapshotEpoch},${account.snapshotScale + 1}"] ??
        s1;
    final a1 = s1 - account.snapshotS;
    final a2 = BigInt.from((s2 - s1) / conversionValue);

    return BigInt.from(((a1 + a2) * account.snapshotD / account.snapshotP)) /
        conversionValue;
  }
}
