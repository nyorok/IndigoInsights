import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indigo_insights/api/vy_finance_api/services/vy_finance_pool_service.dart';
import 'package:indigo_insights/models/indigo_asset.dart';
import 'package:indigo_insights/models/vy_finance/vy_finance_asset_pool.dart';
import 'package:indigo_insights/models/vy_finance/vy_finance_asset_pool_information.dart';

final vyFinanceAssetPoolProvider =
    FutureProvider.family<List<VyFinanceAssetPool>, IndigoAsset>(
        (ref, indigoAsset) async {
  final poolService = VyFinancePoolService();
  final poolInformations =
      await ref.watch(vyFinanceAssetPoolInformationProvider.future);

  final assetPools = await Future.wait(poolInformations
      .where((info) =>
          info.assetA == indigoAsset.asset || info.assetB == indigoAsset.asset)
      .map(poolService.fetchAssetPool));

  return assetPools.expand((e) => e).toList();
});

final vyFinanceAssetPoolInformationProvider =
    FutureProvider<List<VyFinanceAssetPoolInformation>>((ref) async {
  return await VyFinancePoolService().fetchAssetPoolInformation();
});
