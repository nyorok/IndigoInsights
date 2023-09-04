import 'package:indigo_insights/api/vy_finance_api/vy_finance_api.dart';
import 'package:indigo_insights/models/vy_finance/vy_finance_asset_pool.dart';
import 'package:indigo_insights/models/vy_finance/vy_finance_asset_pool_information.dart';

class VyFinancePoolService extends VyFinanceApi {
  Future<List<VyFinanceAssetPoolInformation>> fetchAssetPoolInformation() {
    return getAll<VyFinanceAssetPoolInformation>(
        '', VyFinanceAssetPoolInformation.fromJson);
  }

  Future<List<VyFinanceAssetPool>> fetchAssetPool(
      VyFinanceAssetPoolInformation poolInformation) {
    return getAll<VyFinanceAssetPool>(
        '&tokenAUnit=${poolInformation.symbolA}&tokenBUnit=${poolInformation.symbolB}',
        VyFinanceAssetPool.fromJson);
  }
}
