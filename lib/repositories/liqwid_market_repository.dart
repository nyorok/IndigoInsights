import 'package:indigo_insights/api/liqwid_api/liqwid_service.dart';
import 'package:indigo_insights/utils/cached_result.dart';

class LiqwidMarketRepository {
  static const _ttl = Duration(minutes: 5);

  final LiqwidService _service;
  CachedResult<List<LiqwidMarket>>? _cache;

  LiqwidMarketRepository(this._service);

  Future<List<LiqwidMarket>> getMarkets() async {
    if (_cache != null && _cache!.isValid(_ttl)) return _cache!.value;
    final result = await _service.fetchMarkets();
    _cache = CachedResult(result);
    return result;
  }

  void invalidateCache() => _cache = null;
}
