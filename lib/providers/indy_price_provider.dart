import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/api/indigo_api/services/indy_service.dart';

final indyPriceProvider = FutureProvider<double>((ref) async {
  return await IndyService().fetchPrice();
});
