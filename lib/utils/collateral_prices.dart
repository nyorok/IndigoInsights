import 'package:indigo_insights/models/asset_price.dart';
import 'package:indigo_insights/models/asset_status.dart';

/// Resolves the price of an (iAsset, collateral) pair, expressed as
/// **collateral units per 1 iAsset** — the same convention `/api/asset-prices`
/// uses.
///
/// That endpoint does not always publish every pair (iUSD/ADA is regularly
/// absent), and call sites used to fall back to `1.0`, which silently inflated
/// collateral ratios by the collateral's price. This fills the gaps with a USD
/// cross-rate derived from the pairs that *are* published:
///
///   collateralUsd = iAssetUsd / (collateral per iAsset)
///   missingPair   = iAssetUsd / collateralUsd
class CollateralPrices {
  CollateralPrices._(this._pairs, this._iAssetUsd, this._collateralUsd);

  final Map<String, double> _pairs;
  final Map<String, double> _iAssetUsd;
  final Map<String, double> _collateralUsd;

  static String _key(String asset, String collateral) => '$asset|$collateral';

  factory CollateralPrices.from(
    List<AssetStatus> statuses,
    List<AssetPrice> prices,
  ) {
    final pairs = <String, double>{
      for (final p in prices)
        if (p.price > 0) _key(p.asset, p.collateralAsset): p.price,
    };
    final iAssetUsd = <String, double>{
      for (final s in statuses)
        if (s.usdPrice > 0) s.asset: s.usdPrice,
    };

    // Every published pair implies a USD price for its collateral; average the
    // implied values so one stale pair can't skew the result.
    final sums = <String, double>{};
    final counts = <String, int>{};
    for (final p in prices) {
      final assetUsd = iAssetUsd[p.asset];
      if (assetUsd == null || p.price <= 0) continue;
      final implied = assetUsd / p.price;
      sums[p.collateralAsset] = (sums[p.collateralAsset] ?? 0) + implied;
      counts[p.collateralAsset] = (counts[p.collateralAsset] ?? 0) + 1;
    }
    final collateralUsd = <String, double>{
      for (final e in sums.entries) e.key: e.value / counts[e.key]!,
    };

    return CollateralPrices._(pairs, iAssetUsd, collateralUsd);
  }

  /// Collateral units per 1 iAsset, or null when it cannot be derived.
  /// Never guesses — callers must handle null rather than show a wrong number.
  double? priceFor(String asset, String collateralAsset) {
    final direct = _pairs[_key(asset, collateralAsset)];
    if (direct != null && direct > 0) return direct;

    final assetUsd = _iAssetUsd[asset];
    final collUsd = _collateralUsd[collateralAsset];
    if (assetUsd != null && collUsd != null && collUsd > 0) {
      return assetUsd / collUsd;
    }
    return null;
  }

  /// USD price of a collateral token, when derivable.
  double? collateralUsd(String collateralAsset) =>
      _collateralUsd[collateralAsset];
}
