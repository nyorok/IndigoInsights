import 'package:indigo_insights/api/indigo_api/services/asset_status_service.dart';
import 'package:indigo_insights/models/asset_status.dart';
import 'package:indigo_insights/utils/cached_result.dart';

class AssetStatusRepository {
  static const _ttl = Duration(minutes: 5);

  final AssetStatusService _service;
  CachedResult<List<AssetStatus>>? _cache;

  AssetStatusRepository(this._service);

  DateTime? get lastFetchedAt => _cache?.fetchedAt;

  Future<List<AssetStatus>> getStatuses() async {
    if (_cache != null && _cache!.isValid(_ttl)) return _cache!.value;
    final result = await _service.fetchAssetStatuses();
    _cache = CachedResult(result);
    return result;
  }

  void invalidateCache() => _cache = null;
}
