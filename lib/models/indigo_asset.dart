import 'package:collection/collection.dart';
import 'package:indigo_insights/models/collateral_pair.dart';

class IndigoAsset {
  final String asset;
  final String outputHash;
  final int outputIndex;
  final List<CollateralPair> collateralAssets;

  final double debtMintingFee;
  final double? liquidationProcessingFee;
  final double? stabilityPoolWithdrawalFee;
  final double? redemptionProcessingFee;
  final double? redemptionReimbursementFee;

  IndigoAsset({
    required this.asset,
    required this.outputHash,
    required this.outputIndex,
    required this.collateralAssets,
    required this.debtMintingFee,
    this.liquidationProcessingFee,
    this.stabilityPoolWithdrawalFee,
    this.redemptionProcessingFee,
    this.redemptionReimbursementFee,
  });

  // ADA-collateral pair preferred (empty collateralAsset), fallback to first.
  CollateralPair? get _adaPair =>
      collateralAssets.firstWhereOrNull((p) => p.collateralAsset.isEmpty) ??
      collateralAssets.firstOrNull;

  // Backwards-compatible single-value getters (ADA pair).
  double? get liquidationRatio => _adaPair?.liquidationRatioPercent;
  double? get maintenanceRatio => _adaPair?.maintenanceRatioPercent;
  double? get rmr => _adaPair?.redemptionRatioPercent;

  // Per-collateral lookups — O(n_pairs ≤ 3), safe everywhere.
  double getLiquidationRatio(String collateralAsset) =>
      collateralAssets
          .firstWhereOrNull((p) => p.collateralAsset == collateralAsset)
          ?.liquidationRatioPercent ??
      110.0;

  double getMaintenanceRatio(String collateralAsset) =>
      collateralAssets
          .firstWhereOrNull((p) => p.collateralAsset == collateralAsset)
          ?.maintenanceRatioPercent ??
      115.0;

  factory IndigoAsset.fromJson(Map<String, dynamic> json) {
    final pairs = (json['collateralAssets'] as List<dynamic>? ?? [])
        .map((e) => CollateralPair.fromJson(e as Map<String, dynamic>))
        .toList();

    return IndigoAsset(
      asset: json['name'] as String,
      outputHash: (json['outputHash'] as String?) ?? '',
      outputIndex: (json['outputIndex'] as int?) ?? 0,
      collateralAssets: pairs,
      debtMintingFee:
          (json['debtMintingFeePercent'] as num?)?.toDouble() ?? 0.0,
      liquidationProcessingFee:
          (json['liquidationProcessingFeePercent'] as num?)?.toDouble(),
      stabilityPoolWithdrawalFee:
          (json['stabilityPoolWithdrawalFeePercent'] as num?)?.toDouble(),
      redemptionProcessingFee:
          (json['redemptionProcessingFeePercent'] as num?)?.toDouble(),
      redemptionReimbursementFee:
          (json['redemptionReimbursementPercent'] as num?)?.toDouble(),
    );
  }
}
