import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indigo_insights/api/indigo_api/services/stability_pool_account_service.dart';
import 'package:indigo_insights/models/stability_pool_account.dart';

final stabilityPoolAccountProvider =
    FutureProvider<List<StabilityPoolAccount>>((ref) async {
  return await StabilityPoolAccountService().fetchStabilityPoolAccounts();
});
