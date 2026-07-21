import 'package:indigo_insights/api/danogo_api/danogo_service.dart';
import 'package:indigo_insights/utils/cached_result.dart';

class DanogoPoolRepository {
  static const _ttl = Duration(minutes: 5);

  final DanogoService _service;
  CachedResult<List<DanogoPool>>? _cache;

  DanogoPoolRepository(this._service);

  Future<List<DanogoPool>> getPools() async {
    if (_cache != null && _cache!.isValid(_ttl)) return _cache!.value;
    final result = await _service.fetchPools();
    _cache = CachedResult(result);
    return result;
  }

  void invalidateCache() => _cache = null;
}
