import 'dart:convert';

import 'package:http/http.dart' as http;

class VyFinanceApi {
  final String baseUrl = 'https://api.vyfi.io/lp?networkId=1&v2=true';

  Future<List<T>> getAll<T>(
      String endpoint, T Function(Map<String, dynamic>) fromJson) async {
    final Uri apiUrl = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        dynamic jsonData = json.decode(response.body);

        if (jsonData is Map && jsonData.containsKey("data")) {
          jsonData = jsonData["data"];
        }

        if (jsonData is List) {
          return jsonData.map((data) => fromJson(data)).toList();
        }

        throw Exception("Response was not a List");
      } else {
        throw Exception('Status Code ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('VyFinanceApi ($endpoint) - Error: $error');
    }
  }
}
