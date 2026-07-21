import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class DanogoPool {
  final String ticker;

  /// Supply APY already in percent (e.g. 2.63).
  final double supplyApyPercent;

  DanogoPool({required this.ticker, required this.supplyApyPercent});
}

/// Minimal client for the Danogo (dano.finance) float-lending API.
class DanogoService {
  static const _url =
      'https://float-lending-bff.api.danogo.io/api/v1/load-main-screen';

  Future<List<DanogoPool>> fetchPools() async {
    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Origin': 'https://dano.finance',
        },
        body: jsonEncode({'loanOwnerNfts': <String>[]}),
      );
      if (response.statusCode != 200) {
        throw Exception('Status Code ${response.statusCode}');
      }
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final pools =
          ((decoded['data'] as Map<String, dynamic>)['pools'] as List<dynamic>)
              .map((e) => e as Map<String, dynamic>);
      return pools
          .map(
            (e) => DanogoPool(
              ticker: (e['tokenTicker'] as String?) ?? '',
              supplyApyPercent: (e['supplyApy'] as num?)?.toDouble() ?? 0.0,
            ),
          )
          .toList();
    } catch (error) {
      if (kDebugMode) print(error);
      throw Exception('DanogoService - Error: $error');
    }
  }
}
