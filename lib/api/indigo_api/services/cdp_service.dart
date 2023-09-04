import 'package:indigo_insights/api/indigo_api/indigo_api.dart';
import 'package:indigo_insights/models/cdp.dart';

class CdpService extends IndigoApi {
  Future<List<Cdp>> fetchCdps() {
    return getAll<Cdp>('/api/cdps', Cdp.fromJson);
  }
}
