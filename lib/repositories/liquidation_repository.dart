import 'package:indigo_insights/api/indigo_api/services/liquidation_service.dart';
import 'package:indigo_insights/models/liquidation.dart';
import 'package:indigo_insights/utils/cached_result.dart';

class LiquidationRepository {
  static const _ttl = Duration(minutes: 10);

  final LiquidationService _service;
  CachedResult<List<Liquidation>>? _cache;

  LiquidationRepository(this._service);

  DateTime? get lastFetchedAt => _cache?.fetchedAt;

  Future<List<Liquidation>> getLiquidations() async {
    if (_cache != null && _cache!.isValid(_ttl)) return _cache!.value;
    final result = await _service.fetchLiquidations();
    _cache = CachedResult(result);
    return result;
  }

  Future<List<Liquidation>> getLiquidationsForAsset(String asset) async {
    final all = await getLiquidations();
    return all.where((l) => l.asset == asset).toList();
  }

  void invalidateCache() => _cache = null;
}
