import 'package:indigo_insights/models/yield.dart';

enum Dex { minswapV2, sundaeswapV3, wingridersV2, minswapStableSwap, unknown }

class LiquidityPoolYield {
  final Dex dex;
  final String assetA;
  final String assetB;
  final double tradingFeesApr;
  final List<Yield> yields;

  String get pair => "$assetA/$assetB";
  double get farmingApr => yields.fold(0, (sum, yield) => sum + yield.apr);

  LiquidityPoolYield({
    required this.dex,
    required this.assetA,
    required this.assetB,
    required this.tradingFeesApr,
    required this.yields,
  });

  factory LiquidityPoolYield.fromJson(Map<String, dynamic> json) {
    return LiquidityPoolYield(
      dex: _dexNameToEnum(json['dex']),
      assetA: _assetIdToName(json['asset_a']),
      assetB: _assetIdToName(json['asset_b']),
      tradingFeesApr: json['base_apr'].toDouble(),
      yields: (json['yields'] as List)
          .map((e) => Yield.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  bool hasAsset(String asset) => assetA == asset || assetB == asset;

  Map<String, dynamic> toJson() {
    return {
      'dex': dex,
      'asset_a': assetA,
      'asset_b': assetB,
      'base_apr': tradingFeesApr,
      'yields': yields.map((e) => e.toJson()).toList(),
    };
  }

  static Dex _dexNameToEnum(String dexId) => switch (dexId) {
    "MinswapStableSwap" => Dex.minswapStableSwap,
    "SundaeswapStableSwap" => Dex.sundaeswapV3,
    "WingridersV2" => Dex.wingridersV2,
    _ => Dex.unknown,
  };

  static String _assetIdToName(String assetId) => switch (assetId) {
    "f66d78b4a3cb3d37afa0ec36461e51ecbde00f26c8f0a68f94b69880.69555344" =>
      "iUSD",
    "f66d78b4a3cb3d37afa0ec36461e51ecbde00f26c8f0a68f94b69880.69425443" =>
      "iBTC",
    "f66d78b4a3cb3d37afa0ec36461e51ecbde00f26c8f0a68f94b69880.69455448" =>
      "iETH",
    "f66d78b4a3cb3d37afa0ec36461e51ecbde00f26c8f0a68f94b69880.69534f4c" =>
      "iSOL",
    "25c5de5f5b286073c593edfd77b48abc7a48e5a4f3d4cd9d428ff935.55534443" =>
      "wanUSDC",
    "25c5de5f5b286073c593edfd77b48abc7a48e5a4f3d4cd9d428ff935.425443" =>
      "wanBTC",
    "25c5de5f5b286073c593edfd77b48abc7a48e5a4f3d4cd9d428ff935.455448" =>
      "wanETH",
    "25c5de5f5b286073c593edfd77b48abc7a48e5a4f3d4cd9d428ff935.534f4c" =>
      "wanSOL",
    "c48cbb3d5e57ed56e276bc45f99ab39abe94e6cd7ac39fb402da47ad.0014df105553444d" =>
      "USDM",
    "8db269c3ec630e06ae29f74bc39edd1f87c819f1056206e879a1cd61.446a65644d6963726f555344" =>
      "DJED",
    "fe7c786ab321f41c654ef6c1af7b3250a613c24e4213e0425a7ae456.55534441" =>
      "USDA",
    "9a9693a9a37912a5097918f97918d15240c92ab729a0b7c4aa144d77.53554e444145" =>
      "SUNDAE",
    "533bb94a8850ee3ccbe483106489399112b74c905342cb1792a797a0.494e4459" =>
      "INDY",
    "c0ee29a85b13209423b10447d3c2e6a50641a15c57770e27cb9d5073.57696e67526964657273" =>
      "WRT",
    "29d222ce763455e3d7a09a665ce554f00ac89d2e99a1a83d267170c6.4d494e" => "MIN",
    _ => assetId,
  };
}
