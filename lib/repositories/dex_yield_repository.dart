import 'package:indigo_insights/api/indigo_api/services/dex_yield_service.dart';
import 'package:indigo_insights/models/liquidity_pool_yield.dart';
import 'package:indigo_insights/utils/cached_result.dart';

class DexYieldRepository {
  static const _ttl = Duration(minutes: 5);

  final DexYieldService _service;
  CachedResult<List<LiquidityPoolYield>>? _cache;

  DexYieldRepository(this._service);

  DateTime? get lastFetchedAt => _cache?.fetchedAt;

  Future<List<LiquidityPoolYield>> getYields() async {
    if (_cache != null && _cache!.isValid(_ttl)) return _cache!.value;
    final result = await _service.fetchLiquidityPoolYields();
    _cache = CachedResult(result);
    return result;
  }

  void invalidateCache() => _cache = null;
}
