import 'package:indigo_insights/api/indigo_api/indigo_api.dart';
import 'package:indigo_insights/models/apr_entry.dart';

class AprService extends IndigoApi {
  Future<List<AprEntry>> fetchAprs() =>
      getAll('/api/v3/apr', AprEntry.fromJson);
}
