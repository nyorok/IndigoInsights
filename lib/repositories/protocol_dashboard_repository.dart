import 'package:indigo_insights/models/asset_price.dart';
import 'package:indigo_insights/models/asset_status.dart';
import 'package:indigo_insights/models/cdp.dart';
import 'package:indigo_insights/models/indigo_asset.dart';
import 'package:indigo_insights/models/liquidation.dart';
import 'package:indigo_insights/models/stability_pool.dart';
import 'package:indigo_insights/models/stake_history.dart';
import 'package:indigo_insights/repositories/asset_price_repository.dart';
import 'package:indigo_insights/repositories/asset_status_repository.dart';
import 'package:indigo_insights/repositories/cdp_repository.dart';
import 'package:indigo_insights/repositories/indigo_asset_repository.dart';
import 'package:indigo_insights/repositories/indy_price_repository.dart';
import 'package:indigo_insights/repositories/liquidation_repository.dart';
import 'package:indigo_insights/repositories/stability_pool_repository.dart';
import 'package:indigo_insights/repositories/stake_history_repository.dart';
import 'package:indigo_insights/utils/cached_result.dart';

class DashboardData {
  final List<AssetStatus> assetStatuses;
  final List<AssetPrice> assetPrices;
  final double indyPrice;
  final List<Cdp> cdps;
  final List<StabilityPool> stabilityPools;
  final List<Liquidation> liquidations;
  final List<StakeHistory> stakeHistory;
  final List<IndigoAsset> indigoAssets;

  const DashboardData({
    required this.assetStatuses,
    required this.assetPrices,
    required this.indyPrice,
    required this.cdps,
    required this.stabilityPools,
    required this.liquidations,
    required this.stakeHistory,
    required this.indigoAssets,
  });
}

class ProtocolDashboardRepository {
  static const _ttl = Duration(minutes: 5);

  final AssetStatusRepository _assetStatus;
  final AssetPriceRepository _assetPrices;
  final IndyPriceRepository _indyPrice;
  final CdpRepository _cdps;
  final StabilityPoolRepository _pools;
  final LiquidationRepository _liquidations;
  final StakeHistoryRepository _stakeHistory;
  final IndigoAssetRepository _indigoAssets;

  CachedResult<DashboardData>? _cache;

  ProtocolDashboardRepository(
    this._assetStatus,
    this._assetPrices,
    this._indyPrice,
    this._cdps,
    this._pools,
    this._liquidations,
    this._stakeHistory,
    this._indigoAssets,
  );

  Future<DashboardData> getDashboardData() async {
    if (_cache != null && _cache!.isValid(_ttl)) return _cache!.value;

    final results = await Future.wait([
      _assetStatus.getStatuses(),
      _assetPrices.getPrices(),
      _indyPrice.getPrice(),
      _cdps.getCdps(),
      _pools.getPools(),
      _liquidations.getLiquidations(),
      _stakeHistory.getHistory(),
      _indigoAssets.getAssets(),
    ]);

    final data = DashboardData(
      assetStatuses: results[0] as List<AssetStatus>,
      assetPrices: results[1] as List<AssetPrice>,
      indyPrice: results[2] as double,
      cdps: results[3] as List<Cdp>,
      stabilityPools: results[4] as List<StabilityPool>,
      liquidations: results[5] as List<Liquidation>,
      stakeHistory: results[6] as List<StakeHistory>,
      indigoAssets: results[7] as List<IndigoAsset>,
    );

    _cache = CachedResult(data);
    return data;
  }
}
