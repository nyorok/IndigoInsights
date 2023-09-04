import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class IndigoApi {
  final String baseUrl = 'https://analytics.indigoprotocol.io';

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
      if (kDebugMode) {
        print(error);
      }
      throw Exception('IndigoApi ($endpoint) - Error: $error');
    }
  }

  Future<T> get<T>(
      String endpoint, T Function(Map<String, dynamic>) fromJson) async {
    final Uri apiUrl = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        dynamic jsonData = json.decode(response.body);
        return fromJson(jsonData);
      } else {
        throw Exception('Status Code ${response.statusCode}');
      }
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      throw Exception('IndigoApi ($endpoint) - Error: $error');
    }
  }
}
