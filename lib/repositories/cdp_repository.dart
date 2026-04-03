import 'package:indigo_insights/api/indigo_api/services/cdp_service.dart';
import 'package:indigo_insights/models/asset_interest_rate.dart';
import 'package:indigo_insights/models/cdp.dart';
import 'package:indigo_insights/utils/cached_result.dart';

class CdpRepository {
  static const _ttl = Duration(minutes: 5);

  final CdpService _service;
  CachedResult<List<Cdp>>? _cdpCache;
  CachedResult<List<AssetInterestRate>>? _interestRateCache;

  CdpRepository(this._service);

  DateTime? get lastFetchedAt => _cdpCache?.fetchedAt;

  Future<List<Cdp>> getCdps() async {
    if (_cdpCache != null && _cdpCache!.isValid(_ttl)) return _cdpCache!.value;
    final result = await _service.fetchCdps();
    _cdpCache = CachedResult(result);
    return result;
  }

  Future<List<AssetInterestRate>> getAssetInterestRates() async {
    if (_interestRateCache != null && _interestRateCache!.isValid(_ttl)) {
      return _interestRateCache!.value;
    }
    final result = await _service.fetchAssetInterestRates();
    _interestRateCache = CachedResult(result);
    return result;
  }

  void invalidateCache() {
    _cdpCache = null;
    _interestRateCache = null;
  }
}
