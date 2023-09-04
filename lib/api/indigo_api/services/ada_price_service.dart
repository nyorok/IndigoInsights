import 'package:indigo_insights/api/indigo_api/indigo_api.dart';

class AdaPriceService extends IndigoApi {
  Future<double> fetchAdaPrice() {
    return get<double>('/api/price?from=ADA&to=USD', (p) => p['price']);
  }
}
