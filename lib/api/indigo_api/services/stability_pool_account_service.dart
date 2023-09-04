import 'package:indigo_insights/api/indigo_api/indigo_api.dart';
import 'package:indigo_insights/models/stability_pool_account.dart';

class StabilityPoolAccountService extends IndigoApi {
  Future<List<StabilityPoolAccount>> fetchStabilityPoolAccounts() {
    return getAll<StabilityPoolAccount>(
        '/api/stability-pools-accounts', StabilityPoolAccount.fromJson);
  }
}
