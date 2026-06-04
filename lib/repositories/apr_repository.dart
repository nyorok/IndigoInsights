import 'package:indigo_insights/api/indigo_api/services/apr_service.dart';
import 'package:indigo_insights/utils/cached_result.dart';

class AprRepository {
  static const _ttl = Duration(minutes: 5);

  final AprService _service;
  CachedResult<Map<String, double>>? _cache;

  AprRepository(this._service);

  Future<Map<String, double>> getAprs() async {
    if (_cache != null && _cache!.isValid(_ttl)) return _cache!.value;
    final entries = await _service.fetchAprs();
    final map = {for (final e in entries) e.key: e.value};
    _cache = CachedResult(map);
    return map;
  }

  void invalidateCache() => _cache = null;
}
