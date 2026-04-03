import 'package:indigo_insights/api/indigo_api/services/redemption_service.dart';
import 'package:indigo_insights/models/redemption.dart';
import 'package:indigo_insights/utils/cached_result.dart';

class RedemptionRepository {
  static const _ttl = Duration(minutes: 10);

  final RedemptionService _service;
  final Map<String, CachedResult<List<Redemption>>> _cache = {};

  RedemptionRepository(this._service);

  Future<List<Redemption>> getRedemptionsForAsset(String asset) async {
    final cached = _cache[asset];
    if (cached != null && cached.isValid(_ttl)) return cached.value;
    final result = await _service.fetchRedemptionHistory(asset);
    _cache[asset] = CachedResult(result);
    return result;
  }

  void invalidateCache([String? asset]) {
    if (asset != null) {
      _cache.remove(asset);
    } else {
      _cache.clear();
    }
  }
}
