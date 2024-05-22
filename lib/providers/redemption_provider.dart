import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indigo_insights/api/indigo_api/services/redemption_service.dart';
import 'package:indigo_insights/models/redemption.dart';

final redemptionsProvider = FutureProvider<List<Redemption>>((ref) async {
  return await RedemptionService().fetchRedemptionHistory();
});
