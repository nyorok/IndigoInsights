import 'package:indigo_insights/api/indigo_api/services/stability_pool_service.dart';
import 'package:indigo_insights/models/stability_pool.dart';
import 'package:indigo_insights/utils/cached_result.dart';

class StabilityPoolRepository {
  static const _ttl = Duration(minutes: 5);

  final StabilityPoolService _service;
  CachedResult<List<StabilityPool>>? _cache;

  StabilityPoolRepository(this._service);

  DateTime? get lastFetchedAt => _cache?.fetchedAt;

  Future<List<StabilityPool>> getPools() async {
    if (_cache != null && _cache!.isValid(_ttl)) return _cache!.value;
    final result = await _service.fetchStabilityPools();
    _cache = CachedResult(result);
    return result;
  }

  void invalidateCache() => _cache = null;
}
