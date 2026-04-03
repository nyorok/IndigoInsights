import 'package:flutter/material.dart';
import 'package:indigo_insights/models/indigo_asset.dart';
import 'package:indigo_insights/repositories/solvency_repository.dart';
import 'package:indigo_insights/service_locator.dart';
import 'package:indigo_insights/theme/gradients.dart';
import 'package:indigo_insights/utils/async_builder.dart';
import 'package:indigo_insights/widgets/amount_percentage_chart.dart';

class StabilityPoolSolvencyChart extends StatelessWidget {
  const StabilityPoolSolvencyChart({super.key, required this.indigoAsset});

  final IndigoAsset indigoAsset;

  @override
  Widget build(BuildContext context) {
    return AsyncBuilder(
      fetcher: () => sl<SolvencyRepository>().getForAsset(indigoAsset),
      builder: (stabilityPoolSolvencyData) {
        return AmountPercentageChart(
          currency: indigoAsset.asset,
          labels: const ['Balance'],
          data: [stabilityPoolSolvencyData],
          colors: const [Colors.blueAccent],
          gradients: [greenBlueGradient],
        );
      },
      errorBuilder: (error, retry) => Text(error.toString()),
    );
  }
}
