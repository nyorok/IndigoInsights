import 'package:flutter/material.dart';

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
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 3.0),
      child: Row(mainAxisSize: MainAxisSize.min, children: _buildIcons()),
    );
  }

  List<Widget> _buildIcons() {
    switch (riskLevel) {
      case RiskLevel.safe:
        return [const Icon(Icons.bolt, color: Colors.greenAccent, size: 16)];
      case RiskLevel.safeSafe:
        return [
          const Icon(Icons.bolt, color: Colors.greenAccent, size: 16),
          const Icon(Icons.bolt, color: Colors.greenAccent, size: 16),
        ];
      case RiskLevel.safeSafeSafe:
        return [
          const Icon(Icons.bolt, color: Colors.greenAccent, size: 16),
          const Icon(Icons.bolt, color: Colors.greenAccent, size: 16),
          const Icon(Icons.bolt, color: Colors.greenAccent, size: 16),
        ];
      case RiskLevel.warning:
        return [const Icon(Icons.bolt, color: Colors.yellowAccent, size: 16)];
      case RiskLevel.warningWarning:
        return [
          const Icon(Icons.bolt, color: Colors.yellowAccent, size: 16),
          const Icon(Icons.bolt, color: Colors.yellowAccent, size: 16),
        ];
      case RiskLevel.warningWarningWarning:
        return [
          const Icon(Icons.bolt, color: Colors.yellowAccent, size: 16),
          const Icon(Icons.bolt, color: Colors.yellowAccent, size: 16),
          const Icon(Icons.bolt, color: Colors.yellowAccent, size: 16),
        ];
      case RiskLevel.danger:
        return [const Icon(Icons.bolt, color: Colors.redAccent, size: 16)];
      case RiskLevel.dangerDanger:
        return [
          const Icon(Icons.bolt, color: Colors.redAccent, size: 16),
          const Icon(Icons.bolt, color: Colors.redAccent, size: 16),
        ];
      case RiskLevel.dangerDangerDanger:
        return [
          const Icon(Icons.bolt, color: Colors.redAccent, size: 16),
          const Icon(Icons.bolt, color: Colors.redAccent, size: 16),
          const Icon(Icons.bolt, color: Colors.redAccent, size: 16),
        ];
    }
  }
}
