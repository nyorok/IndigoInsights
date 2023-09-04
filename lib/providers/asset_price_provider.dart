import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indigo_insights/api/indigo_api/services/asset_price_service.dart';
import 'package:indigo_insights/models/asset_price.dart';

final assetPricesProvider = FutureProvider<List<AssetPrice>>((ref) async {
  return await AssetPriceService().fetchAssetPrices();
});
