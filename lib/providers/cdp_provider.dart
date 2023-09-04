import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indigo_insights/api/indigo_api/services/cdp_service.dart';
import 'package:indigo_insights/models/cdp.dart';

final cdpsProvider = FutureProvider<List<Cdp>>((ref) async {
  return await CdpService().fetchCdps();
});
