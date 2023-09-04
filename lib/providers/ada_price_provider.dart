import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indigo_insights/api/indigo_api/services/ada_price_service.dart';

final adaPriceProvider = FutureProvider<double>((ref) async {
  return await AdaPriceService().fetchAdaPrice();
});
