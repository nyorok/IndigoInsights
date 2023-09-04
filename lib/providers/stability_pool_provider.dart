import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indigo_insights/api/indigo_api/services/stability_pool_service.dart';
import 'package:indigo_insights/models/stability_pool.dart';

final stabilityPoolProvider = FutureProvider<List<StabilityPool>>((ref) async {
  return await StabilityPoolService().fetchStabilityPools();
});
