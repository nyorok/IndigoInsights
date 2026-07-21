import 'dart:convert';

import 'package:indigo_insights/models/stability_pool_account.dart';

BigInt conversionValue = BigInt.from(10).pow(24);

// V3: per-collateral reward stream inside asset_states
class SpAssetState {
  final String collateralAsset;
  final BigInt sumVal;
  final Map<String, BigInt> epochToScaleToSum;

  SpAssetState({
    required this.collateralAsset,
    required this.sumVal,
    required this.epochToScaleToSum,
  });

  factory SpAssetState.fromJson(Map<String, dynamic> json) {
    final rawEts = json['epochToScaleToSum'];
    final Map<String, BigInt> etsMap = {};
    if (rawEts is List) {
      for (final entry in rawEts) {
        final row = entry as Map<String, dynamic>;
        final epoch = row['epoch'] as String;
        final scale = row['scale'] as String;
        final val = row['sumVal'] as String;
        etsMap['$epoch,$scale'] = BigInt.parse(val);
      }
    }
    return SpAssetState(
      collateralAsset: (json['asset'] as String?) ?? '',
      sumVal: BigInt.parse((json['sumVal'] as String?) ?? '0'),
      epochToScaleToSum: etsMap,
    );
  }
}

// https://github.com/IndigoProtocol/indigo-smart-contracts/blob/main/src/Indigo/Contracts/StabilityPool/Common.hs#L169C1-L191C4
class StabilityPool {
  final String asset;

  double get totalAmount => snapshotD / conversionValue;

  final BigInt snapshotD;
  final BigInt snapshotP;
  final BigInt? snapshotS;
  final int snapshotEpoch;
  final int snapshotScale;

  // V3: per-collateral reward streams; empty for pre-V3 records
  final List<SpAssetState> assetStates;

  // V2 compat: single global epoch-to-scale-to-sum (null in V3)
  final Map<String, BigInt> epochToScaleToSum;

  StabilityPool({
    required this.asset,
    required this.snapshotD,
    required this.snapshotP,
    this.snapshotS,
    required this.snapshotEpoch,
    required this.snapshotScale,
    required this.epochToScaleToSum,
    this.assetStates = const [],
  });

  factory StabilityPool.fromJson(Map<String, dynamic> json) {
    final Map<String, BigInt> parsedEts = {};
    final rawEts = json['epoch_to_scale_to_sum'];
    if (rawEts is String) {
      final decoded = jsonDecode(rawEts) as Map<String, dynamic>;
      decoded.forEach((key, value) {
        parsedEts[key] = BigInt.parse(value as String);
      });
    }

    List<SpAssetState> assetStates = [];
    final rawAs = json['asset_states'];
    if (rawAs is String) {
      final decoded = jsonDecode(rawAs) as List<dynamic>;
      assetStates = decoded
          .map((e) => SpAssetState.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return StabilityPool(
      asset: json['asset'] as String,
      snapshotD: BigInt.parse(json['snapshotD'] as String),
      snapshotP: BigInt.parse(json['snapshotP'] as String),
      snapshotS: json['snapshotS'] != null
          ? BigInt.parse(json['snapshotS'] as String)
          : null,
      snapshotEpoch: json['snapshotEpoch'] as int,
      snapshotScale: json['snapshotScale'] as int,
      epochToScaleToSum: parsedEts,
      assetStates: assetStates,
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

  // Returns ADA unclaimed rewards (V2 path). Returns 0 when data is unavailable (V3).
  double getAccountUnclaimedRewards(StabilityPoolAccount account) {
    final accountS = account.snapshotS;
    if (accountS == null) return 0;

    final key = '${account.snapshotEpoch},${account.snapshotScale}';
    final s1 = epochToScaleToSum[key];
    if (s1 == null) return 0;

    final s2 = epochToScaleToSum[
            '${account.snapshotEpoch},${account.snapshotScale + 1}'] ??
        s1;
    final a1 = s1 - accountS;
    final a2 = BigInt.from((s2 - s1) / conversionValue);

    return BigInt.from(((a1 + a2) * account.snapshotD / account.snapshotP)) /
        conversionValue;
  }

  /// V3: unclaimed rewards per collateral asset ('' = ADA, else policy.hexName).
  /// Same Liquity-style formula as [getAccountUnclaimedRewards], applied to each
  /// collateral reward stream in [assetStates] against the account's matching
  /// S snapshot in `asset_sums`. Amounts of different collaterals are different
  /// tokens — never sum them without converting.
  Map<String, double> getAccountUnclaimedRewardsByCollateral(
      StabilityPoolAccount account) {
    final rewards = <String, double>{};
    final key = '${account.snapshotEpoch},${account.snapshotScale}';
    final nextKey = '${account.snapshotEpoch},${account.snapshotScale + 1}';

    for (final state in assetStates) {
      final s1 = state.epochToScaleToSum[key];
      if (s1 == null) continue;
      // Account snapshot missing for this stream = account joined before the
      // stream started accruing; its S snapshot is 0.
      final accountS = account.assetSums[state.collateralAsset] ?? BigInt.zero;

      final s2 = state.epochToScaleToSum[nextKey] ?? s1;
      final a1 = s1 - accountS;
      final a2 = BigInt.from((s2 - s1) / conversionValue);

      final amount =
          BigInt.from(((a1 + a2) * account.snapshotD / account.snapshotP)) /
              conversionValue;
      if (amount > 0) rewards[state.collateralAsset] = amount;
    }

    // V2 fallback: single ADA stream stored on the pool itself.
    if (rewards.isEmpty && account.snapshotS != null) {
      final v2 = getAccountUnclaimedRewards(account);
      if (v2 > 0) rewards[''] = v2;
    }

    return rewards;
  }
}
