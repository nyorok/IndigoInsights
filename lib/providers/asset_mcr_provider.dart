import 'package:flutter_riverpod/flutter_riverpod.dart';

final assetMcrProvider = Provider.family<double, String>(
    (ref, asset) => switch (asset) { "iUSD" => 1.20, _ => 1.10 });
