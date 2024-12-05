import 'package:flutter/material.dart';
import 'package:indigo_insights/utils/calculation.dart';

class PercentageGain extends StatelessWidget {
  final double oldValue;
  final double newValue;

  const PercentageGain(this.oldValue, this.newValue, {super.key});

  @override
  Widget build(BuildContext context) {
    final change = percentageChange(oldValue, newValue);
    return Row(
      children: [
        Text(
          '${change.sign > 0 ? '+' : ''}${change.toStringAsFixed(2)}%',
          style: TextStyle(color: change >= 0 ? Colors.green : Colors.red),
        ),
      ],
    );
  }
}
