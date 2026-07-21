import 'package:indigo_insights/api/indigo_api/indigo_api.dart';
import 'package:indigo_insights/models/liquidation.dart';

class LiquidationService extends IndigoApi {
  // /api/liquidations was removed in the V3 indexer migration. The raw list
  // lives at /api/v3/liquidations; /api/v3/analytics/liquidations is the
  // aggregated alternative but lacks id/dates/oracle price fields.
  Future<List<Liquidation>> fetchLiquidations() {
    return getAll<Liquidation>('/api/v3/liquidations', Liquidation.fromJson);
  }
}
