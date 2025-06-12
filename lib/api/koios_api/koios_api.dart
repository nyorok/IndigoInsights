import 'dart:convert';
import 'dart:developer'; // For log

import 'package:http/http.dart' as http;

class KoiosApi {
  final String _baseUrl = 'https://api.koios.rest/api/v1';

  Future<String?> getPaymentCredential(String address) async {
    final Uri apiUrl = Uri.parse('$_baseUrl/address_utxos');

    final Map<String, dynamic> requestBody = {
      "_addresses": [address],
      "_extended": false,
    };

    try {
      final response = await http.post(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        if (jsonData.isNotEmpty) {
          final String? paymentCred = jsonData[0]['payment_cred'] as String?;
          return paymentCred;
        } else {
          log('No UTXOs found for address: $address');
          return null;
        }
      } else {
        log(
          'Koios API failed with status code ${response.statusCode}: ${response.body}',
        );
        return null;
      }
    } catch (error) {
      log('Error getting payment credential for address $address: $error');
      return null;
    }
  }
}
