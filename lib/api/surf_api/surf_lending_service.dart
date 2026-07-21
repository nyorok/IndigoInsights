import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class SurfPool {
  final String ticker;

  /// Supply APY in percent (API returns a fraction, e.g. 0.0374 → 3.74).
  final double supplyApyPercent;

  SurfPool({required this.ticker, required this.supplyApyPercent});
}

/// Minimal client for the Surf Lending (surflending.org) API.
class SurfLendingService {
  static const _url = 'https://surflending.org/api/getAllPoolInfos';

  // Surf's API sends no Access-Control-Allow-Origin header, so browsers
  // block direct calls. On web, tunnel through a public CORS proxy; native
  // platforms call the API directly.
  static const _fetchUrl = kIsWeb ? 'https://cors.eu.org/$_url' : _url;

  Future<List<SurfPool>> fetchPools() async {
    try {
      final response = await http.get(
        Uri.parse(_fetchUrl),
        headers: {'Accept': '*/*'},
      );
      if (response.statusCode != 200) {
        throw Exception('Status Code ${response.statusCode}');
      }
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final poolInfos = decoded['poolInfos'] as Map<String, dynamic>;
      return poolInfos.values
          .map((e) => e as Map<String, dynamic>)
          .map(
            (e) => SurfPool(
              ticker:
                  ((e['asset'] as Map<String, dynamic>)['ticker'] as String?) ??
                      '',
              supplyApyPercent:
                  ((e['supplyApy'] as num?)?.toDouble() ?? 0.0) * 100,
            ),
          )
          .toList();
    } catch (error) {
      if (kDebugMode) print(error);
      throw Exception('SurfLendingService - Error: $error');
    }
  }
}
