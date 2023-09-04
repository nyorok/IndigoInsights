import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indigo_insights/api/coinmarketcap/market_pair_service.dart';
import 'package:indigo_insights/models/coinmarketcap/market_pair.dart';

final marketPairProvider = FutureProvider<MarketPair>((ref) async {
  return await MarketPairService().fetchMarketPair();
});
