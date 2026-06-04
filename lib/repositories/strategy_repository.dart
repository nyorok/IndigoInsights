import 'package:collection/collection.dart';
import 'package:indigo_insights/models/asset_interest_rate.dart';
import 'package:indigo_insights/models/asset_price.dart';
import 'package:indigo_insights/models/indigo_asset.dart';
import 'package:indigo_insights/models/liquidity_pool_yield.dart';
import 'package:indigo_insights/models/stability_pool.dart';
import 'package:indigo_insights/repositories/asset_price_repository.dart';
import 'package:indigo_insights/repositories/cdp_repository.dart';
import 'package:indigo_insights/repositories/dex_yield_repository.dart';
import 'package:indigo_insights/repositories/indigo_asset_repository.dart';
import 'package:indigo_insights/repositories/indy_price_repository.dart';
import 'package:indigo_insights/repositories/stability_pool_repository.dart';
import 'package:indigo_insights/utils/cached_result.dart';

typedef LeverageData = ({
  String asset,
  double interestRate,
  double? rmr,
  double? mcr,
  double? liquidationRatio,
  double assetPrice,
  double debtMintingFee,
});

typedef StabilityPoolStrategyData = ({
  String title,
  double strategyYield,
  double poolYield,
  double interestRate,
  double? rmr,
  double? mcr,
  double? liquidationRatio,
  double debtMintingFee,
});

typedef StablePoolStrategyData = ({
  String title,
  double strategyYield,
  double tradingFeesApr,
  double farmingApr,
  double interestRate,
  double? rmr,
  double? mcr,
  double? liquidationRatio,
  double debtMintingFee,
});

double _incentivesPerYear(String asset) =>
    switch (asset) {
      'iUSD' => 8000,
      'iBTC' => 2000,
      'iETH' => 500,
      'iSOL' => 120,
      _ => 0,
    } *
    365 /
    5;

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

// Returns the global price for an asset (collateral_asset == "").
double? _globalPrice(List<AssetPrice> prices, String asset) =>
    prices.firstWhereOrNull((p) => p.asset == asset && p.collateralAsset.isEmpty)?.price ??
    prices.firstWhereOrNull((p) => p.asset == asset)?.price;

class StrategyRepository {
  static const _ttl = Duration(minutes: 5);

  final IndigoAssetRepository _assets;
  final AssetPriceRepository _prices;
  final CdpRepository _cdps;
  final StabilityPoolRepository _pools;
  final IndyPriceRepository _indyPrice;
  final DexYieldRepository _dexYields;

  CachedResult<List<LeverageData>>? _leverageCache;
  CachedResult<List<StabilityPoolStrategyData>>? _spFarmingCache;
  CachedResult<List<StablePoolStrategyData>>? _stablePoolCache;

  StrategyRepository(
    this._assets,
    this._prices,
    this._cdps,
    this._pools,
    this._indyPrice,
    this._dexYields,
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

    for (final iAsset in indigoAssets) {
      final interestRate = irMap[iAsset.asset]?.interestRate ?? 0.0;
      final price = _globalPrice(assetPrices, iAsset.asset) ?? 0.0;

      leverages.add((
        asset: iAsset.asset,
        interestRate: interestRate * 100,
        rmr: iAsset.rmr,
        mcr: iAsset.maintenanceRatio,
        liquidationRatio: iAsset.liquidationRatio,
        assetPrice: price,
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
      _indyPrice.getPrice(),
      _assets.getAssets(),
      _cdps.getAssetInterestRates(),
    ]);

    final assetPrices = results[0] as List<AssetPrice>;
    final stabilityPools = results[1] as List<StabilityPool>;
    final indyPrice = results[2] as double;
    final indigoAssets = results[3] as List<IndigoAsset>;
    final interestRates = results[4] as List<AssetInterestRate>;

    final irMap = _buildInterestRateMap(interestRates);
    final List<StabilityPoolStrategyData> strategies = [];

    for (final sp in stabilityPools) {
      final asset = sp.asset;
      final spTotal = sp.totalAmount;
      final iAsset = indigoAssets.firstWhere((ia) => ia.asset == asset);
      final aprice = _globalPrice(assetPrices, asset) ?? 1.0;

      final stabilityPoolApr = spTotal > 0
          ? (_incentivesPerYear(asset) * indyPrice) / (spTotal * aprice)
          : 0.0;
      final interestRate = irMap[asset]?.interestRate ?? 0.0;

      strategies.add((
        title: asset,
        strategyYield: (stabilityPoolApr - interestRate) * 100,
        poolYield: stabilityPoolApr * 100,
        interestRate: interestRate * 100,
        rmr: iAsset.rmr,
        mcr: iAsset.maintenanceRatio,
        liquidationRatio: iAsset.liquidationRatio,
        debtMintingFee: iAsset.debtMintingFee,
      ));
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
        rmr: iAsset.rmr,
        mcr: iAsset.maintenanceRatio,
        liquidationRatio: iAsset.liquidationRatio,
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
