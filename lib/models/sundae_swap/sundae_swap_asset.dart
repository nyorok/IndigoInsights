import 'package:indigo_insights/models/sundae_swap/sundae_swap_asset_pool.dart';

class SundaeSwapAsset {
  final String asset;
  final List<SundaeSwapAssetPool> pools;

  SundaeSwapAsset({
    required this.asset,
    required this.pools,
  });

  factory SundaeSwapAsset.fromJson(String asset, Map<String, dynamic> json) {
    final pools = json['pools'] as List<dynamic>;

    return SundaeSwapAsset(
      asset: asset,
      pools: pools.map((e) => SundaeSwapAssetPool.fromJson(e)).toList(),
    );
  }
}
