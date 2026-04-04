import 'package:flutter/material.dart';
import 'package:indigo_insights/theme/app_color_scheme.dart';

enum RiskLevel {
  safe,
  safeSafe,
  safeSafeSafe,
  warning,
  warningWarning,
  warningWarningWarning,
  danger,
  dangerDanger,
  dangerDangerDanger,
}

class StrategyRisk extends StatelessWidget {
  const StrategyRisk({super.key, required this.riskLevel});

  final RiskLevel riskLevel;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 2),
      child: Row(mainAxisSize: MainAxisSize.min, children: _buildIcons(colors)),
    );
  }

  List<Widget> _buildIcons(AppColorScheme colors) {
    final (count, color) = switch (riskLevel) {
      RiskLevel.safe => (1, colors.success),
      RiskLevel.safeSafe => (2, colors.success),
      RiskLevel.safeSafeSafe => (3, colors.success),
      RiskLevel.warning => (1, colors.warning),
      RiskLevel.warningWarning => (2, colors.warning),
      RiskLevel.warningWarningWarning => (3, colors.warning),
      RiskLevel.danger => (1, colors.error),
      RiskLevel.dangerDanger => (2, colors.error),
      RiskLevel.dangerDangerDanger => (3, colors.error),
    };
    return List.generate(
      count,
      (_) => Icon(Icons.bolt, color: color, size: 16),
    );
  }
}
