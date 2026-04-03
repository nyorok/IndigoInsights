import 'package:indigo_insights/api/indigo_api/services/indy_service.dart';
import 'package:indigo_insights/utils/cached_result.dart';

class IndyPriceRepository {
  static const _ttl = Duration(minutes: 2);

  final IndyService _service;
  CachedResult<double>? _cache;

  IndyPriceRepository(this._service);

  DateTime? get lastFetchedAt => _cache?.fetchedAt;

  Future<double> getPrice() async {
    if (_cache != null && _cache!.isValid(_ttl)) return _cache!.value;
    final result = await _service.fetchPrice();
    _cache = CachedResult(result);
    return result;
  }

  void invalidateCache() => _cache = null;
}
