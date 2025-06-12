import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/api/koios_api/koios_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payment_credential_provider.g.dart';

@riverpod
Future<String?> fetchPaymentCredential(
  Ref ref, {
  required String address,
}) async {
  return await KoiosApi().getPaymentCredential(address);
}
