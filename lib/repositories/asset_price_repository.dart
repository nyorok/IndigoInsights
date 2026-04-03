import 'package:indigo_insights/api/indigo_api/services/asset_price_service.dart';
import 'package:indigo_insights/models/asset_price.dart';
import 'package:indigo_insights/utils/cached_result.dart';

class AssetPriceRepository {
  static const _ttl = Duration(minutes: 2);

  final AssetPriceService _service;
  CachedResult<List<AssetPrice>>? _cache;

  AssetPriceRepository(this._service);

  DateTime? get lastFetchedAt => _cache?.fetchedAt;

  Future<List<AssetPrice>> getPrices() async {
    if (_cache != null && _cache!.isValid(_ttl)) return _cache!.value;
    final result = await _service.fetchAssetPrices();
    _cache = CachedResult(result);
    return result;
  }

  void invalidateCache() => _cache = null;
}
