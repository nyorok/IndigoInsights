import 'package:flutter/material.dart';
import 'package:indigo_insights/theme/app_color_scheme.dart';
import 'package:indigo_insights/theme/gradients.dart';

/// Card variants matching the Indigo Insights design system.
enum IICardVariant {
  /// Default dark card — `surface` background, no border.
  grey,

  /// Accent panel — purple gradient with border (e.g. 24h Activity card).
  accentPanel,

  /// Flat section — transparent background, no border (e.g. TVL by Asset).
  flat,
}

/// Design-system card.
///
/// Wraps [Material] + [InkWell] so ripple / hover states work natively,
/// preserving accessibility and pointer-cursor on web/desktop.
class IICard extends StatelessWidget {
  const IICard({
    super.key,
    required this.child,
    this.variant = IICardVariant.grey,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
    this.width,
    this.height,
  });

  final Widget child;
  final IICardVariant variant;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);

    BoxDecoration decoration;
    switch (variant) {
      case IICardVariant.grey:
        decoration = BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
        );
      case IICardVariant.accentPanel:
        decoration = BoxDecoration(
          gradient: accentPanelGradient(),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.primaryBorder, width: 1),
        );
      case IICardVariant.flat:
        decoration = const BoxDecoration();
    }

    Widget content = Container(
      width: width,
      height: height,
      decoration: decoration,
      padding: padding,
      child: child,
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: content,
        ),
      );
    }

    return content;
  }
}
