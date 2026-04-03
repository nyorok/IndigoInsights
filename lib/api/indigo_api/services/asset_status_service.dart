import 'package:indigo_insights/api/indigo_api/indigo_api.dart';
import 'package:indigo_insights/models/asset_status.dart';

class AssetStatusService extends IndigoApi {
  List<AssetStatus> parseAssetStatuses(Map<String, dynamic> jsonData) {
    final List<AssetStatus> assetStatusList = [];

    jsonData.forEach((asset, data) {
      final typed = Map<String, dynamic>.from(data as Map);
      typed['asset'] = asset;
      assetStatusList.add(AssetStatus.fromJson(typed));
    });

    return assetStatusList;
  }

  Future<List<AssetStatus>> fetchAssetStatuses() {
    return get<List<AssetStatus>>('/api/assets/analytics', parseAssetStatuses);
  }
}
