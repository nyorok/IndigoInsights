import 'package:indigo_insights/api/coinmarketcap/coinmarketcap_api.dart';
import 'package:indigo_insights/models/coinmarketcap/market_pair.dart';

class MarketPairService extends CoinMarketCapApi {
  final path =
      'cryptocurrency/market-pairs/latest?slug=indigo-protocol&start=1&limit=100&category=spot&centerType=all&sort=cmc_rank_advanced&direction=desc';

  Future<MarketPair> fetchMarketPair() {
    return get<MarketPair>(path, MarketPair.fromJson);
  }
}
