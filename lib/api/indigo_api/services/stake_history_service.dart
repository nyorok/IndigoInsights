import 'package:indigo_insights/api/indigo_api/indigo_api.dart';
import 'package:indigo_insights/models/stake_history.dart';

class StakeHistoryService extends IndigoApi {
  Future<List<StakeHistory>> fetchStakeHistories() {
    return getAll<StakeHistory>(
        '/api/staking-manager/history?page=1&perPage=1000000000',
        StakeHistory.fromJson);
  }
}
