import 'package:indigo_insights/api/indigo_api/services/indigo_asset_service.dart';
import 'package:indigo_insights/models/indigo_asset.dart';
import 'package:indigo_insights/utils/cached_result.dart';

class IndigoAssetRepository {
  static const _ttl = Duration(minutes: 30);

  final IndigoAssetService _service;
  CachedResult<List<IndigoAsset>>? _cache;

  IndigoAssetRepository(this._service);

  DateTime? get lastFetchedAt => _cache?.fetchedAt;

  Future<List<IndigoAsset>> getAssets() async {
    if (_cache != null && _cache!.isValid(_ttl)) return _cache!.value;
    final result = await _service.fetchIndigoAssets();
    result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    _cache = CachedResult(result);
    return result;
  }

  void invalidateCache() => _cache = null;
}
