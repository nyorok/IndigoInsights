import 'package:indigo_insights/api/indigo_api/indigo_api.dart';
import 'package:indigo_insights/models/asset_price.dart';

class AssetPriceService extends IndigoApi {
  Future<List<AssetPrice>> fetchAssetPrices() {
    return getAll<AssetPrice>('/api/asset-prices', AssetPrice.fromJson);
  }
}
