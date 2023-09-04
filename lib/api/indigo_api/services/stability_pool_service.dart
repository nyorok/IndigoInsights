import 'package:indigo_insights/api/indigo_api/indigo_api.dart';
import 'package:indigo_insights/models/stability_pool.dart';

class StabilityPoolService extends IndigoApi {
  Future<List<StabilityPool>> fetchStabilityPools() {
    return getAll<StabilityPool>(
        '/api/stability-pools', StabilityPool.fromJson);
  }
}
