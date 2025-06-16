import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indigo_insights/api/indigo_api/services/dex_yield_service.dart';
import 'package:indigo_insights/models/liquidity_pool_yield.dart';

final dexYieldProvider = FutureProvider<List<LiquidityPoolYield>>((ref) async {
  return await DexYieldService().fetchLiquidityPoolYields();
});
