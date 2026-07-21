import 'package:indigo_insights/api/surf_api/surf_lending_service.dart';
import 'package:indigo_insights/utils/cached_result.dart';

class SurfPoolRepository {
  static const _ttl = Duration(minutes: 5);

  final SurfLendingService _service;
  CachedResult<List<SurfPool>>? _cache;

  SurfPoolRepository(this._service);

  Future<List<SurfPool>> getPools() async {
    if (_cache != null && _cache!.isValid(_ttl)) return _cache!.value;
    final result = await _service.fetchPools();
    _cache = CachedResult(result);
    return result;
  }

  void invalidateCache() => _cache = null;
}
