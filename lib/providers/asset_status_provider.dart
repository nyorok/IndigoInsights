import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indigo_insights/api/indigo_api/services/asset_status_service.dart';
import 'package:indigo_insights/models/asset_status.dart';

final assetStatusProvider = FutureProvider<List<AssetStatus>>((ref) async {
  return await AssetStatusService().fetchAssetStatuses();
});
