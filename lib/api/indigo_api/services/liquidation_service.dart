import 'package:indigo_insights/api/indigo_api/indigo_api.dart';
import 'package:indigo_insights/models/liquidation.dart';

class LiquidationService extends IndigoApi {
  Future<List<Liquidation>> fetchLiquidations() {
    return getAll<Liquidation>('/api/liquidations', Liquidation.fromJson);
  }
}
