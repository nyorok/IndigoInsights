import 'dart:convert';

import 'package:http/http.dart' as http;

class SundaeSwapApi {
  final String baseUrl = 'https://stats.sundaeswap.finance';

  Future<T> post<T>(String endpoint, T Function(Map<String, dynamic>) fromJson,
      {Object? body}) async {
    final Uri apiUrl = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await http.post(apiUrl, body: jsonEncode(body));

      if (response.statusCode == 200) {
        dynamic jsonData = json.decode(response.body);

        if (jsonData is Map && jsonData.containsKey("data")) {
          jsonData = jsonData["data"];
        }

        return fromJson(jsonData);
      } else {
        throw Exception('Status Code ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('SundaeSwapApi ($endpoint) - Error: $error');
    }
  }
}
