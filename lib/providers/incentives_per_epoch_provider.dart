import 'package:hooks_riverpod/hooks_riverpod.dart';

final stabilityPoolIncentivesPerYearProvider = Provider.family<double, String>(
  (ref, asset) =>
      switch (asset) {
        'iUSD' => 8000,
        'iBTC' => 2000,
        'iETH' => 500,
        'iSOL' => 120,
        _ => 0,
      } *
      365 /
      5,
);
