import 'package:flutter/material.dart';
import 'package:indigo_insights/theme/app_color_scheme.dart';
import 'package:indigo_insights/theme/app_text_styles.dart';

/// The only scheme shipped today.  Add light_scheme.dart, blue_scheme.dart,
/// etc. alongside this file without touching any widget code.
const darkScheme = AppColorScheme(
  // Surfaces
  canvas: Color(0xFF0A0A0A),
  surface: Color(0xFF18181B),
  surfaceRaised: Color(0xFF27272A),
  border: Color(0xFF27272A),
  // Text
  textPrimary: Color(0xFFFFFFFF),
  textSecondary: Color(0xFFA1A1AA),
  textMuted: Color(0xFF71717A),
  // Brand accent (iSOL purple)
  primary: Color(0xFF9945FF),
  primarySurface: Color(0x229945FF), // ~13 %
  primaryBorder: Color(0x409945FF), // ~25 %
  // Semantic
  success: Color(0xFF4ADE80),
  error: Color(0xFFEF4444),
  warning: Color(0xFFFBC02D),
  // iAsset palette
  iUsd: Color(0xFF70D150),
  iBtc: Color(0xFFFF9416),
  iEth: Color(0xFFFFFFFF),
  iSol: Color(0xFF9945FF),
);

/// Pre-built text styles for the dark scheme.
final darkStyles = AppTextStyles.build(color: darkScheme.textPrimary);
