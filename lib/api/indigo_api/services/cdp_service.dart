import 'package:indigo_insights/api/indigo_api/indigo_api.dart';
import 'package:indigo_insights/models/cdp.dart';
import 'package:indigo_insights/models/cdps_stats.dart';

class CdpService extends IndigoApi {
  Future<List<Cdp>> fetchCdps() {
    return getAll<Cdp>('/api/cdps', Cdp.fromJson);
  }

  Future<List<CdpsStats>> fetchCdpsStats(String asset, DateTime startOn) {
    return getAll<CdpsStats>(
        '/api/cdps/stats?page=1&perPage=50000&filterBy=$asset&fromTimestamp=${startOn.millisecondsSinceEpoch / 1000}',
        CdpsStats.fromJson);
  }
}
