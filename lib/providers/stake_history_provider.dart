import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indigo_insights/api/indigo_api/services/stake_history_service.dart';
import 'package:indigo_insights/models/stake_history.dart';

final stakeHistoriesProvider = FutureProvider<List<StakeHistory>>((ref) async {
  return await StakeHistoryService().fetchStakeHistories();
});
