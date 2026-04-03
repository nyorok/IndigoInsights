import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/api/indigo_api/services/cdp_service.dart';
import 'package:indigo_insights/models/asset_interest_rate.dart';
import 'package:indigo_insights/models/cdp.dart';

final cdpsProvider = FutureProvider<List<Cdp>>((ref) async {
  return await CdpService().fetchCdps();
});

final assetInterestRatesProvider = FutureProvider<List<AssetInterestRate>>((
  ref,
) async {
  return await CdpService().fetchAssetInterestRates();
});
