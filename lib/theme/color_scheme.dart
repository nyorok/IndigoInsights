import 'package:flutter/material.dart';

const Color primaryRed = Color.fromRGBO(255, 51, 68, 1);
const Color secondaryRed = Color.fromRGBO(255, 103, 53, 1);

const Color primaryPurple = Color.fromRGBO(120, 60, 174, 1);
const Color secondaryPurple = Color.fromRGBO(120, 61, 169, 1);

const Color primaryBackground = Color.fromRGBO(22, 36, 79, 1);
const Color secondaryBackground = Color.fromRGBO(11, 19, 43, 1);

const Color primaryBorder = Color.fromRGBO(34, 45, 81, 1);

const Color onSelection = secondaryPurple;

const Color secondaryText = Color.fromRGBO(148, 163, 184, 1);

ColorScheme colorScheme = const ColorScheme(
  background: primaryBackground,
  brightness: Brightness.light,
  error: Colors.red,
  errorContainer: null,
  onError: Colors.red,
  onErrorContainer: null,
  inversePrimary: null,
  inverseSurface: null,
  onBackground: primaryBorder,
  onPrimary: Colors.white,
  onPrimaryContainer: null,
  onSecondary: Colors.red,
  onSecondaryContainer: null,
  onSurface: Colors.white,
  onSurfaceVariant: null,
  onTertiary: secondaryText,
  onTertiaryContainer: null,
  outline: null,
  outlineVariant: primaryBorder,
  primary: secondaryBackground,
  primaryContainer: onSelection,
  secondary: secondaryBackground,
  secondaryContainer: null,
  scrim: null,
  shadow: null,
  surface: secondaryBackground,
  surfaceTint: null,
  surfaceVariant: null,
  tertiary: null,
  tertiaryContainer: null,
);
