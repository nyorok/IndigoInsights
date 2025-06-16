import 'package:flutter/material.dart';

const Color primaryRed = Color.fromRGBO(255, 51, 68, 1);
const Color secondaryRed = Color.fromRGBO(255, 103, 53, 1);
const Color onSuccess = Color.fromRGBO(85, 241, 85, 1);

const Color primaryPurple = Color.fromRGBO(106, 61, 232, 1);

const Color primaryBackground = Color.fromRGBO(22, 36, 79, 1);
const Color secondaryBackground = Color.fromRGBO(11, 19, 43, 1);

const Color primaryBorder = Color.fromRGBO(34, 45, 81, 1);

const Color onSelection = Color.fromRGBO(61, 3, 148, 1);

const Color secondaryText = Color.fromRGBO(148, 163, 184, 1);

ColorScheme colorScheme = const ColorScheme(
  brightness: Brightness.light,
  error: Colors.red,
  errorContainer: null,
  onError: Colors.red,
  onErrorContainer: null,
  inversePrimary: null,
  inverseSurface: null,
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
  surface: primaryBackground,
  surfaceContainerLow: secondaryBackground,
  surfaceTint: null,
  surfaceContainerHighest: null,
  tertiary: null,
  tertiaryContainer: null,
);
