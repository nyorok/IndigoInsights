import 'package:indigo_insights/api/indigo_api/indigo_api.dart';
import 'package:indigo_insights/models/indigo_asset.dart';

class IndigoAssetService extends IndigoApi {
  Future<List<IndigoAsset>> fetchIndigoAssets() {
    return getAll<IndigoAsset>('/api/assets', IndigoAsset.fromJson);
  }
}
