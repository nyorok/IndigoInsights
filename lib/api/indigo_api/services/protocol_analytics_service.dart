import 'package:indigo_insights/api/indigo_api/indigo_api.dart';
import 'package:indigo_insights/models/protocol_analytics.dart';

class ProtocolAnalyticsService extends IndigoApi {
  Future<LoanAnalytics> fetchLoanAnalytics() =>
      get<LoanAnalytics>('/api/v3/analytics/loans', LoanAnalytics.fromJson);

  Future<TvlAnalytics> fetchTvl() =>
      get<TvlAnalytics>('/api/v3/analytics/tvl', TvlAnalytics.fromJson);
}
