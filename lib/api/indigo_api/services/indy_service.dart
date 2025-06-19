import 'package:indigo_insights/api/indigo_api/indigo_api.dart';

class IndyService extends IndigoApi {
  Future<double> fetchPrice() {
    return get('/api/indy-price', (json) => double.parse(json['ada_price']));
  }
}
