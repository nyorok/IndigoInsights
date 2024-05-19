import 'package:flutter/material.dart';
import 'package:indigo_insights/theme/color_scheme.dart';

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

const orangeTransparentGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color.fromRGBO(255, 103, 54, 0.9),
      Color.fromRGBO(255, 103, 54, 0.4),
    ]);

final blueTransparentGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.blue.shade900.withOpacity(0.9),
      Colors.blue.shade900.withOpacity(0.4),
    ]);

final greyTransparentGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.blueGrey.shade900.withOpacity(0.9),
      Colors.blueGrey.shade900.withOpacity(0.6),
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
