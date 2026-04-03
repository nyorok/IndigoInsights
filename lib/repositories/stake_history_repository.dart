import 'package:indigo_insights/api/indigo_api/services/stake_history_service.dart';
import 'package:indigo_insights/models/stake_history.dart';
import 'package:indigo_insights/utils/cached_result.dart';

class StakeHistoryRepository {
  static const _ttl = Duration(minutes: 10);

  final StakeHistoryService _service;
  CachedResult<List<StakeHistory>>? _cache;

  StakeHistoryRepository(this._service);

  DateTime? get lastFetchedAt => _cache?.fetchedAt;

  Future<List<StakeHistory>> getHistory() async {
    if (_cache != null && _cache!.isValid(_ttl)) return _cache!.value;
    final result = await _service.fetchStakeHistories();
    _cache = CachedResult(result);
    return result;
  }

  void invalidateCache() => _cache = null;
}
