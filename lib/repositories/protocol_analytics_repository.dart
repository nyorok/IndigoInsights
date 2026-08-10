import 'package:indigo_insights/api/indigo_api/services/protocol_analytics_service.dart';
import 'package:indigo_insights/models/protocol_analytics.dart';
import 'package:indigo_insights/utils/cached_result.dart';

class ProtocolAnalyticsRepository {
  static const _ttl = Duration(minutes: 5);

  final ProtocolAnalyticsService _service;
  CachedResult<LoanAnalytics>? _loansCache;
  CachedResult<TvlAnalytics>? _tvlCache;

  ProtocolAnalyticsRepository(this._service);

  Future<LoanAnalytics> getLoanAnalytics() async {
    if (_loansCache != null && _loansCache!.isValid(_ttl)) {
      return _loansCache!.value;
    }
    final result = await _service.fetchLoanAnalytics();
    _loansCache = CachedResult(result);
    return result;
  }

  Future<TvlAnalytics> getTvl() async {
    if (_tvlCache != null && _tvlCache!.isValid(_ttl)) return _tvlCache!.value;
    final result = await _service.fetchTvl();
    _tvlCache = CachedResult(result);
    return result;
  }

  void invalidateCache() {
    _loansCache = null;
    _tvlCache = null;
  }
}
