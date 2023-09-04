import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indigo_insights/api/indigo_api/services/liquidation_service.dart';
import 'package:indigo_insights/models/liquidation.dart';

final liquidationProvider = FutureProvider<List<Liquidation>>((ref) async {
  return await LiquidationService().fetchLiquidations();
});
