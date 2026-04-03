import 'package:collection/collection.dart';
import 'package:indigo_insights/models/asset_price.dart';
import 'package:indigo_insights/models/cdp.dart';
import 'package:indigo_insights/models/indigo_asset.dart';
import 'package:indigo_insights/models/stability_pool.dart';
import 'package:indigo_insights/repositories/asset_price_repository.dart';
import 'package:indigo_insights/repositories/cdp_repository.dart';
import 'package:indigo_insights/repositories/stability_pool_repository.dart';
import 'package:indigo_insights/utils/cached_result.dart';
import 'package:indigo_insights/widgets/amount_percentage_chart.dart';

class SolvencyRepository {
  static const _ttl = Duration(minutes: 5);

  final AssetPriceRepository _prices;
  final StabilityPoolRepository _pools;
  final CdpRepository _cdps;

  final Map<String, CachedResult<List<AmountPercentageData>>> _cache = {};

  SolvencyRepository(this._prices, this._pools, this._cdps);

  Future<List<AmountPercentageData>> getForAsset(IndigoAsset indigoAsset) async {
    final cached = _cache[indigoAsset.asset];
    if (cached != null && cached.isValid(_ttl)) return cached.value;

    // All three fire in parallel — upstream TTL caches absorb duplicate calls
    final results = await Future.wait([
      _prices.getPrices(),
      _pools.getPools(),
      _cdps.getCdps(),
    ]);

    final assetPrices = results[0] as List<AssetPrice>;
    final pools = results[1] as List<StabilityPool>;
    final cdpsAll = results[2] as List<Cdp>;

    final assetPrice = assetPrices
        .firstWhere((ap) => ap.asset == indigoAsset.asset)
        .price;
    final stabilityPool = pools.firstWhere((sp) => sp.asset == indigoAsset.asset);
    final spTotal = stabilityPool.totalAmount;

    double calculatePriceChangeToLiquidate(Cdp cdp) {
      final collateralInAsset = cdp.collateralAmount / assetPrice;
      final collateralRatio = collateralInAsset / cdp.mintedAmount;
      final lr = indigoAsset.liquidationRatio / 100;
      if (lr > collateralRatio) {
        throw Exception(
          'Liquidation ratio ($lr) is greater than collateral ratio ($collateralRatio)!',
        );
      }
      return 1.00 - (lr / collateralRatio);
    }

    final cdps = cdpsAll.where((cdp) => cdp.asset == indigoAsset.asset);

    final percentToLiqAndCollateralData = cdps
        .map(
          (cdp) => (
            minted: cdp.mintedAmount,
            percentToLiquidate:
                (calculatePriceChangeToLiquidate(cdp) * 100).round(),
          ),
        )
        .groupFoldBy<int, double>(
          (item) => item.percentToLiquidate,
          (a, b) => (a ?? 0) + b.minted,
        )
        .entries
        .map(
          (entry) =>
              (percentToLiq: entry.key.toDouble() / 100, minted: entry.value),
        )
        .toList()
      ..sort((a, b) => a.percentToLiq.compareTo(b.percentToLiq));

    double spAmount = spTotal;
    final amountPercentageData = percentToLiqAndCollateralData.map((item) {
      spAmount -= item.minted;
      return AmountPercentageData(item.percentToLiq, spAmount);
    }).toList();

    final value = normalizeAmountPercentageData(amountPercentageData, 60, spTotal);
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
