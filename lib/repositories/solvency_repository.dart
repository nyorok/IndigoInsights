import 'package:collection/collection.dart';
import 'package:indigo_insights/models/asset_price.dart';
import 'package:indigo_insights/models/cdp.dart';
import 'package:indigo_insights/models/indigo_asset.dart';
import 'package:indigo_insights/models/stability_pool.dart';
import 'package:indigo_insights/models/asset_status.dart';
import 'package:indigo_insights/repositories/asset_price_repository.dart';
import 'package:indigo_insights/repositories/asset_status_repository.dart';
import 'package:indigo_insights/utils/collateral_prices.dart';
import 'package:indigo_insights/repositories/cdp_repository.dart';
import 'package:indigo_insights/repositories/stability_pool_repository.dart';
import 'package:indigo_insights/utils/cached_result.dart';
import 'package:indigo_insights/widgets/amount_percentage_chart.dart';

class SolvencyRepository {
  static const _ttl = Duration(minutes: 5);

  final AssetPriceRepository _prices;
  final StabilityPoolRepository _pools;
  final CdpRepository _cdps;
  final AssetStatusRepository _statuses;

  final Map<String, CachedResult<List<AmountPercentageData>>> _cache = {};

  SolvencyRepository(this._prices, this._pools, this._cdps, this._statuses);

  Future<List<AmountPercentageData>> getForAsset(IndigoAsset indigoAsset) async {
    final cached = _cache[indigoAsset.asset];
    if (cached != null && cached.isValid(_ttl)) return cached.value;

    final results = await Future.wait([
      _prices.getPrices(),
      _pools.getPools(),
      _cdps.getCdps(),
      _statuses.getStatuses(),
    ]);

    final assetPrices = results[0] as List<AssetPrice>;
    final pools = results[1] as List<StabilityPool>;
    final cdpsAll = results[2] as List<Cdp>;
    final statuses = results[3] as List<AssetStatus>;

    final stabilityPool =
        pools.firstWhereOrNull((sp) => sp.asset == indigoAsset.asset);
    if (stabilityPool == null) {
      _cache[indigoAsset.asset] = CachedResult([]);
      return [];
    }
    final spTotal = stabilityPool.totalAmount;

    // Pre-build O(1) maps so the inner loop over CDPs stays fast. Prices are
    // resolved (not defaulted to 1.0) because /api/asset-prices omits pairs.
    final resolver = CollateralPrices.from(statuses, assetPrices);
    final priceByCollateral = <String, double>{
      for (final collateral in cdpsAll
          .where((c) => c.asset == indigoAsset.asset)
          .map((c) => c.collateralAsset)
          .toSet())
        collateral: ?resolver.priceFor(indigoAsset.asset, collateral),
    };
    final lrByCollateral = <String, double>{
      for (final p in indigoAsset.collateralAssets)
        p.collateralAsset: p.liquidationRatioPercent,
    };

    double percentToLiquidate(Cdp cdp) {
      if (cdp.mintedAmount <= 0) return 0;
      final price = priceByCollateral[cdp.collateralAsset];
      if (price == null || price <= 0) return 0;
      final lrPct = lrByCollateral[cdp.collateralAsset] ?? 110.0;
      final lr = lrPct / 100;
      final cr = (cdp.collateralAmount / price) / cdp.mintedAmount;
      if (lr >= cr) return 0; // already undercollateralised at current price
      return 1.0 - (lr / cr);
    }

    final cdps = cdpsAll.where((cdp) => cdp.asset == indigoAsset.asset);

    final grouped = cdps
        .map((cdp) => (
              minted: cdp.mintedAmount,
              bucket: (percentToLiquidate(cdp) * 100).round(),
            ))
        .groupFoldBy<int, double>(
          (item) => item.bucket,
          (a, b) => (a ?? 0) + b.minted,
        )
        .entries
        .map((e) => (pct: e.key.toDouble() / 100, minted: e.value))
        .toList()
      ..sort((a, b) => a.pct.compareTo(b.pct));

    double spAmount = spTotal;
    final curve = grouped.map((item) {
      spAmount -= item.minted;
      return AmountPercentageData(item.pct, spAmount);
    }).toList();

    final value = normalizeAmountPercentageData(curve, 60, spTotal);
    _cache[indigoAsset.asset] = CachedResult(value);
    return value;
  }

  void invalidateCache([String? asset]) {
    if (asset != null) {
      _cache.remove(asset);
    } else {
      _cache.clear();
    }
  }
}
