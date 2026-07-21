import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class LiqwidMarket {
  final String id;
  final String displayName;

  /// Supply APY in percent (API returns a fraction, e.g. 0.0406 → 4.06).
  final double supplyApyPercent;

  LiqwidMarket({
    required this.id,
    required this.displayName,
    required this.supplyApyPercent,
  });
}

/// Minimal client for the Liqwid lending protocol GraphQL API.
class LiqwidService {
  static const _url = 'https://v2.api.liqwid.finance/graphql';

  Future<List<LiqwidMarket>> fetchMarkets() async {
    const query =
        'query GetMarketsSupply(\$input: MarketsInput) { liqwid { data { '
        'markets(input: \$input) { results { id displayName supplyAPY } } '
        '} } }';

    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {
          'Content-Type': 'application/json',
          'origin': 'https://app.liqwid.finance',
        },
        body: jsonEncode({
          'operationName': 'GetMarketsSupply',
          'variables': {
            'input': {'perPage': 100},
          },
          'query': query,
        }),
      );
      if (response.statusCode != 200) {
        throw Exception('Status Code ${response.statusCode}');
      }
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final results =
          (((decoded['data'] as Map<String, dynamic>)['liqwid']
                      as Map<String, dynamic>)['data']
                  as Map<String, dynamic>)['markets']
              as Map<String, dynamic>;
      return (results['results'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .map(
            (e) => LiqwidMarket(
              id: (e['id'] as String?) ?? '',
              displayName: (e['displayName'] as String?) ?? '',
              supplyApyPercent:
                  ((e['supplyAPY'] as num?)?.toDouble() ?? 0.0) * 100,
            ),
          )
          .toList();
    } catch (error) {
      if (kDebugMode) print(error);
      throw Exception('LiqwidService - Error: $error');
    }
  }
}
