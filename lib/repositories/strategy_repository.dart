import 'package:collection/collection.dart';
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
import 'package:indigo_insights/utils/formatters.dart';

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
      _prices.getPrices(),
    ]);

    final indigoAssets = results[0] as List<IndigoAsset>;
    final assetPrices = results[1] as List<AssetPrice>;

    final List<LeverageData> leverages = [];

    // One entry per (iAsset, collateralAsset) price combination.
    for (final price in assetPrices) {
      final iAsset = indigoAssets.firstWhereOrNull(
        (ia) => ia.asset == price.asset,
      );
      if (iAsset == null) continue;
      final collateralAssetInterestRate =
          iAsset.collateralAssets
              .firstWhereOrNull(
                (ca) => ca.collateralAsset == price.collateralAsset,
              )
              ?.interestRate ??
          0.0;
      leverages.add((
        asset: price.asset,
        collateralAsset: price.collateralAsset,
        interestRate: collateralAssetInterestRate,
        rmr: iAsset.rmr,
        mcr: iAsset.maintenanceRatio,
        liquidationRatio: iAsset.liquidationRatio,
        assetPrice: price.price,
        debtMintingFee: iAsset.debtMintingFee,
      ));
    }

    final result = leverages.sortedBy((e) => e.asset).toList();
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
    final aprMap = results[4] as Map<String, double>;

    final List<StabilityPoolStrategyData> strategies = [];

    for (final sp in stabilityPools) {
      final asset = sp.asset;
      final iAsset = indigoAssets.firstWhereOrNull((ia) => ia.asset == asset);
      if (iAsset == null) continue;

      // SP APR from official endpoint (already in %, same for all collaterals of this asset).
      final indyApr = aprMap['sp_${asset}_indy'] ?? 0.0;
      final adaApr = aprMap['sp_${asset}_ada'] ?? 0.0;
      final poolYield = indyApr + adaApr;

      // One card per collateral price available for this asset.
      final pricesForAsset = assetPrices
          .where((p) => p.asset == asset)
          .toList();
      for (final price in pricesForAsset) {
        final collateralAssetInterestRate =
            iAsset.collateralAssets
                .firstWhereOrNull(
                  (ca) => ca.collateralAsset == price.collateralAsset,
                )
                ?.interestRate ??
            0.0;

        strategies.add((
          title: asset,
          collateralAsset: price.collateralAsset,
          strategyYield: poolYield - (collateralAssetInterestRate),
          poolYield: poolYield,
          interestRate: collateralAssetInterestRate,
          assetPrice: price.price,
          debtMintingFee: iAsset.debtMintingFee,
        ));
      }
    }

    final result = strategies
        .sortedBy((a) => a.strategyYield)
        .reversed
        .toList();
    _spFarmingCache = CachedResult(result);
    return result;
  }

  Future<List<StablePoolStrategyData>> getStablePoolFarmingData() async {
    if (_stablePoolCache != null && _stablePoolCache!.isValid(_ttl)) {
      return _stablePoolCache!.value;
    }

    final results = await Future.wait([
      _assets.getAssets(),
      _dexYields.getYields(),
    ]);

    final indigoAssets = results[0] as List<IndigoAsset>;
    final dexYields = results[1] as List<LiquidityPoolYield>;

    final minswapYields = dexYields
        .where((e) => e.dex == Dex.minswapStableSwap)
        .where((e) => indigoAssets.any((ia) => e.hasAsset(ia.asset)))
        .toList();

    final List<StablePoolStrategyData> strategies = [];
    for (final e in minswapYields) {
      final iAsset = indigoAssets.firstWhere((ia) => e.hasAsset(ia.asset));

      for (final collateralAsset in iAsset.collateralAssets) {
        strategies.add((
          title:
              '${e.pair} (${collateralLabel(collateralAsset.collateralAsset)} Collateral)',
          strategyYield:
              e.tradingFeesApr + e.farmingApr - (collateralAsset.interestRate),
          tradingFeesApr: e.tradingFeesApr,
          farmingApr: e.farmingApr,
          interestRate: collateralAsset.interestRate,
          debtMintingFee: iAsset.debtMintingFee,
        ));
      }
    }

    final result = strategies
        .sortedBy((a) => a.strategyYield)
        .reversed
        .toList();
    _stablePoolCache = CachedResult(result);
    return result;
  }

  void invalidateCache() {
    _leverageCache = null;
    _spFarmingCache = null;
    _stablePoolCache = null;
  }
}
