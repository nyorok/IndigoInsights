import 'package:indigo_insights/api/indigo_api/indigo_api.dart';
import 'package:indigo_insights/models/stability_pool_account.dart';

class StabilityPoolAccountService extends IndigoApi {
  // V3 endpoint: includes per-collateral `asset_sums` (the account's S
  // snapshots), required to compute unclaimed rewards. The legacy
  // /api/stability-pools-accounts omits them (snapshotS is always null there).
  Future<List<StabilityPoolAccount>> fetchStabilityPoolAccounts() {
    return getAll<StabilityPoolAccount>(
        '/api/v3/stability-pools/accounts', StabilityPoolAccount.fromJson);
  }
}
