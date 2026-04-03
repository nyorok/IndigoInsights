import 'package:indigo_insights/api/indigo_api/services/stability_pool_account_service.dart';
import 'package:indigo_insights/models/stability_pool_account.dart';
import 'package:indigo_insights/utils/cached_result.dart';

class StabilityPoolAccountRepository {
  static const _ttl = Duration(minutes: 5);

  final StabilityPoolAccountService _service;
  CachedResult<List<StabilityPoolAccount>>? _cache;

  StabilityPoolAccountRepository(this._service);

  DateTime? get lastFetchedAt => _cache?.fetchedAt;

  Future<List<StabilityPoolAccount>> getAccounts() async {
    if (_cache != null && _cache!.isValid(_ttl)) return _cache!.value;
    final result = await _service.fetchStabilityPoolAccounts();
    _cache = CachedResult(result);
    return result;
  }

  void invalidateCache() => _cache = null;
}
