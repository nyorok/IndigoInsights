import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:indigo_insights/repositories/strategy_repository.dart';
import 'package:indigo_insights/service_locator.dart';
import 'package:indigo_insights/theme/app_color_scheme.dart';
import 'package:indigo_insights/utils/async_builder.dart';
import 'package:indigo_insights/views/insights/strategy/ada_leverage_above_mr/ada_leverage_above_mr_card.dart';
import 'package:indigo_insights/views/insights/strategy/ada_leverage_above_mr/ada_leverage_above_mr_description.dart';
import 'package:indigo_insights/widgets/ii_disclaimer.dart';
import 'package:indigo_insights/widgets/slider_selector.dart';

class AdaLeverageAboveMrContent extends StatefulWidget {
  const AdaLeverageAboveMrContent({super.key});

  @override
  State<AdaLeverageAboveMrContent> createState() =>
      _AdaLeverageAboveMrContentState();
}

class _AdaLeverageAboveMrContentState extends State<AdaLeverageAboveMrContent> {
  double? _collateralRatio;

  @override
  Widget build(BuildContext context) {
    return AsyncBuilder(
      fetcher: () => sl<StrategyRepository>().getLeverageData(),
      builder: (leveragesData) {
        final minCr = leveragesData.map((e) => e.mcr).min;
        const maxCr = 500.0;
        _collateralRatio ??= minCr;

        return SingleChildScrollView(
          child: Column(
            children: [
              Container(
                color: AppColorScheme.of(context).surfaceRaised,
                child: const AdaLeverageAboveMrDescription(),
              ),
              SliderSelector(
                initialValue: minCr,
                minValue: minCr,
                maxValue: maxCr,
                label: 'Min: ${minCr.toStringAsFixed(0)}% (MCR) | Range',
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
                          child: AdaLeverageAboveMrCard(
                            asset: data.asset,
                            interestRate: data.interestRate,
                            redemptionMarginRatio: data.rmr,
                            maintenanceRatio: data.mcr,
                            liquidationRatio: data.liquidationRatio,
                            assetPrice: data.assetPrice,
                            debtMintingFee: data.debtMintingFee,
                            collateralRatio: (_collateralRatio ?? minCr) > data.mcr
                                ? (_collateralRatio ?? minCr)
                                : data.mcr,
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
              const IIDisclaimer(),
            ],
          ),
        );
      },
      errorBuilder: (error, retry) => Text(error.toString()),
    );
  }
}
