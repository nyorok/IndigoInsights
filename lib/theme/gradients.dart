import 'package:flutter/material.dart';
import 'package:indigo_insights/theme/color_scheme.dart';

Color getColorByAsset(String asset) => switch (asset) {
      'iUSD' => const Color(0xFF70D150),
      'iBTC' => const Color(0xFFFF9416),
      'iETH' => Colors.white,
      'iSOL' => const Color(0xFF9945FF),
      _ => Colors.greenAccent
    };

LinearGradient getGradientByAsset(String asset) => switch (asset) {
      'iUSD' => usdTransparentGradient,
      'iBTC' => btcTransparentGradient,
      'iETH' => ethTransparentGradient,
      'iSOL' => solTransparentGradient,
      _ => greenTransparentGradient
    };

const indigoGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color.fromRGBO(63, 1, 161, 1),
      Color.fromRGBO(98, 0, 174, 1),
    ]);

const orangeGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.deepOrange,
      Colors.orangeAccent,
    ]);

final blueGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.blue.shade900,
      Colors.blueAccent,
    ]);

final greyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.blueGrey.shade900,
      Colors.blueGrey,
    ]);

const whiteGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.white38,
      Colors.white10,
    ]);

final btcTransparentGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.white.withOpacity(0.7),
      const Color(0xFFFF9416).withOpacity(0.4),
    ]);

final usdTransparentGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.white.withOpacity(0.7),
      const Color(0xFF70D150).withOpacity(0.4),
    ]);

final ethTransparentGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.white.withOpacity(0.7),
      const Color(0xFF141414).withOpacity(0.4),
    ]);

final solTransparentGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Colors.white.withOpacity(0.7),
    const Color(0xFF00FFA3).withOpacity(0.7),
    const Color(0xFF9945FF).withOpacity(0.6),
  ],
);

final greenTransparentGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.green.shade900.withOpacity(0.9),
      Colors.green.shade900.withOpacity(0.4),
    ]);

final greenBlueGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: const [
      0,
      0.5,
      0.8,
      1
    ],
    colors: [
      Colors.green,
      Colors.blue.shade900,
      secondaryRed,
      primaryRed,
    ]);
