import 'package:indigo_insights/api/indigo_api/indigo_api.dart';
import 'package:indigo_insights/models/liquidity_pool_yield.dart';

class DexYieldService extends IndigoApi {
  Future<List<LiquidityPoolYield>> fetchLiquidityPoolYields() {
    return getAll<LiquidityPoolYield>(
      '/api/yields',
      LiquidityPoolYield.fromJson,
    );
  }
}
