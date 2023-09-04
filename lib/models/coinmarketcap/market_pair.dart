import 'package:indigo_insights/models/coinmarketcap/market.dart';

class MarketPair {
  final String symbol;
  final List<Market> marketPairs;

  MarketPair({required this.symbol, required this.marketPairs});

  factory MarketPair.fromJson(Map<String, dynamic> json) {
    return MarketPair(
        symbol: json['symbol'],
        marketPairs: (json['marketPairs'] as List<Map<String, dynamic>>)
            .map((e) => Market.fromJson(e))
            .toList());
  }
}
