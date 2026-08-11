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

  /// Surf's API sends no Access-Control-Allow-Origin header, so browsers block
  /// direct calls and the app (a static site) has no backend to proxy through.
  /// On web we fall through a list of public CORS proxies — any one of them can
  /// rate-limit or go down, so a single hardcoded proxy is not dependable.
  /// Native platforms call the API directly.
  static List<String> get _candidateUrls => kIsWeb
      ? [
          'https://proxy.cors.sh/$_url',
          'https://cors.eu.org/$_url',
          'https://api.allorigins.win/raw?url=${Uri.encodeComponent(_url)}',
        ]
      : [_url];

  Future<List<SurfPool>> fetchPools() async {
    Object? lastError;
    for (final url in _candidateUrls) {
      try {
        final response =
            await http.get(Uri.parse(url), headers: {'Accept': '*/*'});
        if (response.statusCode != 200) {
          throw Exception('Status Code ${response.statusCode}');
        }
        return _parse(response.body);
      } catch (error) {
        lastError = error;
        if (kDebugMode) print('SurfLendingService ($url): $error');
      }
    }
    throw Exception('SurfLendingService - Error: $lastError');
  }

  List<SurfPool> _parse(String body) {
    final decoded = jsonDecode(body) as Map<String, dynamic>;
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
  }
}
