import 'package:indigo_insights/api/indigo_api/services/indigo_asset_service.dart';
import 'package:indigo_insights/models/indigo_asset.dart';
import 'package:indigo_insights/utils/cached_result.dart';

class IndigoAssetRepository {
  static const _ttl = Duration(minutes: 30);

  final IndigoAssetService _service;
  CachedResult<List<IndigoAsset>>? _cache;

  IndigoAssetRepository(this._service);

  DateTime? get lastFetchedAt => _cache?.fetchedAt;

  static const _preferredOrder = ['iUSD', 'iBTC', 'iETH', 'iSOL'];

  Future<List<IndigoAsset>> getAssets() async {
    if (_cache != null && _cache!.isValid(_ttl)) return _cache!.value;
    final result = await _service.fetchIndigoAssets();
    result.sort((a, b) {
      final ai = _preferredOrder.indexOf(a.asset);
      final bi = _preferredOrder.indexOf(b.asset);
      // Known assets in preferred order, then unknown assets by createdAt
      if (ai == -1 && bi == -1) return a.createdAt.compareTo(b.createdAt);
      if (ai == -1) return 1;
      if (bi == -1) return -1;
      return ai.compareTo(bi);
    });
    _cache = CachedResult(result);
    return result;
  }

  void invalidateCache() => _cache = null;
}
