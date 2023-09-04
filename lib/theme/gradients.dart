import 'package:flutter/material.dart';

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

final limeGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.lime.shade900,
      Colors.limeAccent,
    ]);

final orangeTransparentGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.deepOrange.withOpacity(0.8),
      Colors.orangeAccent.withOpacity(0.4),
    ]);

final blueTransparentGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.blue.shade900.withOpacity(0.8),
      Colors.blue.shade100.withOpacity(0.4),
    ]);

final greyTransparentGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.blueGrey.shade900.withOpacity(0.8),
      Colors.blueGrey.withOpacity(0.4),
    ]);

final greenRedGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: const [
      0,
      0.46,
      0.6,
      1
    ],
    colors: [
      Colors.blue.shade900,
      Colors.blue.shade900,
      Colors.redAccent.shade400,
      Colors.red.shade900,
    ]);
