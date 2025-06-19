import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indigo_insights/api/indigo_api/services/cdp_service.dart';
import 'package:indigo_insights/models/asset_interest_rate.dart';
import 'package:indigo_insights/models/cdp.dart';
import 'package:indigo_insights/models/cdps_stats.dart';

final cdpsProvider = FutureProvider<List<Cdp>>((ref) async {
  return await CdpService().fetchCdps();
});

final cdpsStatsProvider = FutureProvider.family<List<CdpsStats>, String>((
  ref,
  asset,
) async {
  return await CdpService().fetchCdpsStats(
    asset,
    DateTime(DateTime.now().year, 1, 1),
  );
});

final assetInterestRatesProvider = FutureProvider<List<AssetInterestRate>>((
  ref,
) async {
  return await CdpService().fetchAssetInterestRates();
});
