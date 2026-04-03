import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:indigo_insights/repositories/strategy_repository.dart';
import 'package:indigo_insights/service_locator.dart';
import 'package:indigo_insights/theme/color_scheme.dart';
import 'package:indigo_insights/utils/async_builder.dart';
import 'package:indigo_insights/views/insights/strategy/ada_leverage_above_rmr/ada_leverage_above_rmr_card.dart';
import 'package:indigo_insights/views/insights/strategy/ada_leverage_above_rmr/ada_leverage_above_rmr_description.dart';
import 'package:indigo_insights/widgets/financial_disclaimer.dart';
import 'package:indigo_insights/widgets/slider_selector.dart';

class AdaLeverageAboveRmrContent extends StatefulWidget {
  const AdaLeverageAboveRmrContent({super.key});

  @override
  State<AdaLeverageAboveRmrContent> createState() =>
      _AdaLeverageAboveRmrContentState();
}

class _AdaLeverageAboveRmrContentState
    extends State<AdaLeverageAboveRmrContent> {
  double? _collateralRatio;

  @override
  Widget build(BuildContext context) {
    return AsyncBuilder(
      fetcher: () => sl<StrategyRepository>().getLeverageData(),
      builder: (leveragesData) {
        final minCr = leveragesData.map((e) => e.rmr).min;
        const maxCr = 500.0;
        _collateralRatio ??= minCr;

        return SingleChildScrollView(
          child: Column(
            children: [
              Container(
                color: secondaryBackground.withAlpha(150),
                child: const AdaLeverageAboveRmrDescription(),
              ),
              SliderSelector(
                initialValue: minCr,
                minValue: minCr,
                maxValue: maxCr,
                label: 'Min: ${minCr.toStringAsFixed(0)}% (RMR) | Range',
                unit: '%',
                onChanged: (value) => setState(() => _collateralRatio = value),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const double spacing = 8.0;
                    int crossAxisCount = 1;
                    if (constraints.maxWidth > 1200) {
                      crossAxisCount = 4;
                    } else if (constraints.maxWidth > 800) {
                      crossAxisCount = 3;
                    } else if (constraints.maxWidth > 500) {
                      crossAxisCount = 2;
                    }

                    final double itemWidth =
                        (constraints.maxWidth -
                            (crossAxisCount - 1) * spacing) /
                        crossAxisCount;

                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: leveragesData.map((data) {
                        return SizedBox(
                          width: itemWidth,
                          child: AdaLeverageAboveRmrCard(
                            asset: data.asset,
                            interestRate: data.interestRate,
                            redemptionMarginRatio: data.rmr,
                            maintenanceRatio: data.mcr,
                            liquidationRatio: data.liquidationRatio,
                            assetPrice: data.assetPrice,
                            debtMintingFee: data.debtMintingFee,
                            collateralRatio: (_collateralRatio ?? minCr) > data.rmr
                                ? (_collateralRatio ?? minCr)
                                : data.rmr,
                          )
                              .animate()
                              .slideX(duration: 300.ms, curve: Curves.easeInOut)
                              .fadeIn(duration: 600.ms, curve: Curves.easeInOut),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              const FinancialDisclaimer(),
            ],
          ),
        );
      },
      errorBuilder: (error, retry) => Text(error.toString()),
    );
  }
}
