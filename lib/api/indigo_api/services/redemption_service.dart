import 'package:indigo_insights/api/indigo_api/indigo_api.dart';
import 'package:indigo_insights/models/redemption.dart';

class RedemptionService extends IndigoApi {
  Future<List<Redemption>> fetchRedemptionHistory() {
    return getAll<Redemption>(
        '/api/redemptions/list?page=1&perPage=1000000000', Redemption.fromJson);
  }
}
