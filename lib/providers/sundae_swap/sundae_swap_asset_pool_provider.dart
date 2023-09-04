import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indigo_insights/api/sundae_swap_api/services/sundae_swap_asset_pool_service.dart';
import 'package:indigo_insights/models/indigo_asset.dart';
import 'package:indigo_insights/models/sundae_swap/sundae_swap_asset.dart';

final sundaeSwapAssetPoolProvider =
    FutureProvider.family<SundaeSwapAsset, IndigoAsset>(
        (ref, indigoAsset) async {
  return await SundaeSwapAssetPoolService().fetchAssetPool(indigoAsset);
});
