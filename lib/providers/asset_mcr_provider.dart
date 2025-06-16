import 'package:flutter_riverpod/flutter_riverpod.dart';

final assetMcrProvider = Provider.family<double, String>(
  (ref, asset) => switch (asset) {
    "iUSD" => 1.20,
    _ => 1.10,
  },
);

final assetRmrProvider = Provider.family<double, String>(
  (ref, asset) => switch (asset) {
    "iUSD" => 1.85,
    "iBTC" => 1.50,
    "iETH" => 1.50,
    "iSOL" => 1.50,
    _ => 1.50,
  },
);
