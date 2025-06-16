import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indigo_insights/api/indigo_api/services/indigo_asset_service.dart';
import 'package:indigo_insights/models/indigo_asset.dart';

final indigoAssetsProvider = FutureProvider<List<IndigoAsset>>((ref) async {
  final indigoAssets = await IndigoAssetService().fetchIndigoAssets();

  return indigoAssets.sortedBy((a) => a.createdAt);
});
