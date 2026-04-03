import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/api/indigo_api/services/redemption_service.dart';
import 'package:indigo_insights/models/redemption.dart';

final redemptionsProvider =
    FutureProvider.family<List<Redemption>, String>((ref, asset) async {
  return await RedemptionService().fetchRedemptionHistory(asset);
});
