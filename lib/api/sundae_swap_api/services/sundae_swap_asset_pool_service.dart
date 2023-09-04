import 'package:indigo_insights/api/sundae_swap_api/sundae_swap_api.dart';
import 'package:indigo_insights/models/indigo_asset.dart';
import 'package:indigo_insights/models/sundae_swap/sundae_swap_asset.dart';

class SundaeSwapAssetPoolService extends SundaeSwapApi {
  Future<SundaeSwapAsset> fetchAssetPool(IndigoAsset indigoAsset) {
    const String query = '''
      query getPoolsByAssetIds(\$assetIds: [String!]!) {
        pools(assetIds: \$assetIds) {
          ...PoolFragment
        }
      }
      
      fragment PoolFragment on Pool {
        name
        quantityA
        quantityB
      }      
    ''';

    final Map<String, dynamic> variables = {
      "assetIds": [
        "f66d78b4a3cb3d37afa0ec36461e51ecbde00f26c8f0a68f94b69880.${indigoAsset.oracleNftTn.substring(0, 8)}"
      ]
    };

    final body = {
      "operationName": "getPoolsByAssetIds",
      "query": query,
      "variables": variables
    };

    return post<SundaeSwapAsset>(
        '/graphql', (json) => SundaeSwapAsset.fromJson(indigoAsset.asset, json),
        body: body);
  }
}
