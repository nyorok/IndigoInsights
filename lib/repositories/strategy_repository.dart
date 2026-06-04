import 'package:collection/collection.dart';
import 'package:indigo_insights/models/asset_interest_rate.dart';
import 'package:indigo_insights/models/asset_price.dart';
import 'package:indigo_insights/models/indigo_asset.dart';
import 'package:indigo_insights/models/liquidity_pool_yield.dart';
import 'package:indigo_insights/models/stability_pool.dart';
import 'package:indigo_insights/repositories/apr_repository.dart';
import 'package:indigo_insights/repositories/asset_price_repository.dart';
import 'package:indigo_insights/repositories/cdp_repository.dart';
import 'package:indigo_insights/repositories/dex_yield_repository.dart';
import 'package:indigo_insights/repositories/indigo_asset_repository.dart';
import 'package:indigo_insights/repositories/stability_pool_repository.dart';
import 'package:indigo_insights/utils/cached_result.dart';

typedef LeverageData = ({
  String asset,
  String collateralAsset,
  double interestRate,
  double? rmr,
  double? mcr,
  double? liquidationRatio,
  double assetPrice,
  double debtMintingFee,
});

typedef StabilityPoolStrategyData = ({
  String title,
  String collateralAsset,
  double strategyYield,
  double poolYield,
  double interestRate,
  double assetPrice,
  double debtMintingFee,
});

typedef StablePoolStrategyData = ({
  String title,
  double strategyYield,
  double tradingFeesApr,
  double farmingApr,
  double interestRate,
  double debtMintingFee,
});

Map<String, AssetInterestRate> _buildInterestRateMap(
  List<AssetInterestRate> rates,
) {
  final Map<String, AssetInterestRate> map = {};
  for (final ir in rates) {
    // Prefer the ADA-collateral (global) rate when multiple collaterals exist
    if (!map.containsKey(ir.asset) ||
        (ir.collateralAsset.isEmpty && map[ir.asset]!.collateralAsset.isNotEmpty) ||
        (ir.collateralAsset == map[ir.asset]!.collateralAsset &&
            map[ir.asset]!.slot < ir.slot)) {
      map[ir.asset] = ir;
    }
  }
  return map;
}


class StrategyRepository {
  static const _ttl = Duration(minutes: 5);

  final IndigoAssetRepository _assets;
  final AssetPriceRepository _prices;
  final CdpRepository _cdps;
  final StabilityPoolRepository _pools;
  final DexYieldRepository _dexYields;
  final AprRepository _aprs;

  CachedResult<List<LeverageData>>? _leverageCache;
  CachedResult<List<StabilityPoolStrategyData>>? _spFarmingCache;
  CachedResult<List<StablePoolStrategyData>>? _stablePoolCache;

  StrategyRepository(
    this._assets,
    this._prices,
    this._cdps,
    this._pools,
    this._dexYields,
    this._aprs,
  );

  /// Shared data for all 3 leverage strategies (above RMR, above MCR, double above MCR).
  Future<List<LeverageData>> getLeverageData() async {
    if (_leverageCache != null && _leverageCache!.isValid(_ttl)) {
      return _leverageCache!.value;
    }

    final results = await Future.wait([
      _assets.getAssets(),
      _cdps.getAssetInterestRates(),
      _prices.getPrices(),
    ]);

    final indigoAssets = results[0] as List<IndigoAsset>;
    final interestRates = results[1] as List<AssetInterestRate>;
    final assetPrices = results[2] as List<AssetPrice>;

    final irMap = _buildInterestRateMap(interestRates);
    final List<LeverageData> leverages = [];

    // One entry per (iAsset, collateralAsset) price combination.
    for (final price in assetPrices) {
      final iAsset = indigoAssets.firstWhereOrNull((ia) => ia.asset == price.asset);
      if (iAsset == null) continue;
      final interestRate = irMap[price.asset]?.interestRate ?? 0.0;
      leverages.add((
        asset: price.asset,
        collateralAsset: price.collateralAsset,
        interestRate: interestRate * 100,
        rmr: iAsset.rmr,
        mcr: iAsset.maintenanceRatio,
        liquidationRatio: iAsset.liquidationRatio,
        assetPrice: price.price,
        debtMintingFee: iAsset.debtMintingFee,
      ));
    }

    final result = leverages
        .sortedBy((e) => e.asset)
        .toList();
    _leverageCache = CachedResult(result);
    return result;
  }

  Future<List<StabilityPoolStrategyData>> getStabilityPoolFarmingData() async {
    if (_spFarmingCache != null && _spFarmingCache!.isValid(_ttl)) {
      return _spFarmingCache!.value;
    }

    final results = await Future.wait([
      _prices.getPrices(),
      _pools.getPools(),
      _assets.getAssets(),
      _cdps.getAssetInterestRates(),
      _aprs.getAprs(),
    ]);

    final assetPrices = results[0] as List<AssetPrice>;
    final stabilityPools = results[1] as List<StabilityPool>;
    final indigoAssets = results[2] as List<IndigoAsset>;
    final interestRates = results[3] as List<AssetInterestRate>;
    final aprMap = results[4] as Map<String, double>;

    final irMap = _buildInterestRateMap(interestRates);
    final List<StabilityPoolStrategyData> strategies = [];

    for (final sp in stabilityPools) {
      final asset = sp.asset;
      final iAsset = indigoAssets.firstWhereOrNull((ia) => ia.asset == asset);
      if (iAsset == null) continue;
      final interestRate = irMap[asset]?.interestRate ?? 0.0;

      // SP APR from official endpoint (already in %, same for all collaterals of this asset).
      final indyApr = aprMap['sp_${asset}_indy'] ?? 0.0;
      final adaApr = aprMap['sp_${asset}_ada'] ?? 0.0;
      final poolYield = indyApr + adaApr;

      // One card per collateral price available for this asset.
      final pricesForAsset = assetPrices.where((p) => p.asset == asset).toList();
      for (final price in pricesForAsset) {
        strategies.add((
          title: asset,
          collateralAsset: price.collateralAsset,
          strategyYield: poolYield - (interestRate * 100),
          poolYield: poolYield,
          interestRate: interestRate * 100,
          assetPrice: price.price,
          debtMintingFee: iAsset.debtMintingFee,
        ));
      }
    }

    final result = strategies.sortedBy((a) => a.strategyYield).reversed.toList();
    _spFarmingCache = CachedResult(result);
    return result;
  }

  Future<List<StablePoolStrategyData>> getStablePoolFarmingData() async {
    if (_stablePoolCache != null && _stablePoolCache!.isValid(_ttl)) {
      return _stablePoolCache!.value;
    }

    final results = await Future.wait([
      _assets.getAssets(),
      _cdps.getAssetInterestRates(),
      _dexYields.getYields(),
    ]);

    final indigoAssets = results[0] as List<IndigoAsset>;
    final interestRates = results[1] as List<AssetInterestRate>;
    final dexYields = results[2] as List<LiquidityPoolYield>;

    final irMap = _buildInterestRateMap(interestRates);
    final minswapYields = dexYields
        .where((e) => e.dex == Dex.minswapStableSwap)
        .where((e) => indigoAssets.any((ia) => e.hasAsset(ia.asset)))
        .toList();

    final List<StablePoolStrategyData> strategies = [];
    for (final e in minswapYields) {
      final iAsset = indigoAssets.firstWhere((ia) => e.hasAsset(ia.asset));
      final interestRate =
          irMap.values.firstWhereOrNull((ir) => e.hasAsset(ir.asset))?.interestRate ??
          0.0;

      strategies.add((
        title: e.pair,
        strategyYield: e.tradingFeesApr + e.farmingApr - (interestRate * 100),
        tradingFeesApr: e.tradingFeesApr,
        farmingApr: e.farmingApr,
        interestRate: interestRate * 100,
        debtMintingFee: iAsset.debtMintingFee,
      ));
    }

    final result = strategies.sortedBy((a) => a.strategyYield).reversed.toList();
    _stablePoolCache = CachedResult(result);
    return result;
  }

  void invalidateCache() {
    _leverageCache = null;
    _spFarmingCache = null;
    _stablePoolCache = null;
  }
}
