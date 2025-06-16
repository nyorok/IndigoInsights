import 'package:flutter_riverpod/flutter_riverpod.dart';

final stabilityPoolIncentivesPerYearProvider = Provider.family<double, String>(
  (ref, asset) =>
      switch (asset) {
        "iUSD" => 8000,
        "iBTC" => 2000,
        "iETH" => 500,
        "iSOL" => 120,
        _ => 0,
      } *
      365 /
      5,
);

enum Dex { minswap, sundaeswap }

final liquidityPoolIncentivesPerEpochProvider =
    Provider.family<double, ({Dex dex, String asset, String secondaryPair})>((
      ref,
      pair,
    ) {
      final sortedPair = [pair.asset, pair.secondaryPair]..sort();
      final asset1 = sortedPair[0];
      final asset2 = sortedPair[1];

      // Each case must be presorted
      return switch ((pair.dex, asset1, asset2)) {
        (Dex.sundaeswap, "ADA", "iUSD") => 400,

        (Dex.minswap, "ADA", "iUSD") => 2500,
        (Dex.minswap, "ADA", "iBTC") => 600,
        (Dex.minswap, "ADA", "iETH") => 200,
        (Dex.minswap, "ADA", "iSOL") => 100,

        (Dex.minswap, "iUSD", "wanUSDC") => 3000,
        (Dex.minswap, "iBTC", "wanBTC") => 850,
        (Dex.minswap, "iETH", "wanETH") => 250,
        (Dex.minswap, "iSOL", "wanSOL") => 100,
        _ => -999, // Invalid pair
      };
    });
