import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:indigo_insights/models/indigo_asset.dart';
import 'package:indigo_insights/repositories/indigo_asset_repository.dart';
import 'package:indigo_insights/service_locator.dart';
import 'package:indigo_insights/utils/async_builder.dart';

class ScrollableInformationCards extends StatelessWidget {
  final Widget Function(IndigoAsset) cardContentBuilder;

  const ScrollableInformationCards(this.cardContentBuilder, {super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double maxCardWidth = screenWidth - 480 > 480 ? 480 : screenWidth;

    return AsyncBuilder(
      fetcher: () => sl<IndigoAssetRepository>().getAssets(),
      builder: (indigoAssets) {
        final informationCards = indigoAssets.mapIndexed((index, indigoAsset) {
          return ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxCardWidth),
            child: Card(
              elevation: 2,
              margin: const EdgeInsets.all(8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: cardContentBuilder(indigoAsset),
              ),
            ),
          ).animate().slideX(
            duration: ((index + 2) * 100).ms,
            curve: Curves.easeInOut,
          );
        }).toList();

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            const appBarHeight = kToolbarHeight;
            final statusBarHeight = MediaQuery.of(context).padding.top;

            return isWide
                ? SizedBox(
                    height:
                        MediaQuery.of(context).size.height -
                        statusBarHeight -
                        appBarHeight -
                        8,
                    child: SingleChildScrollView(
                      child: Column(children: informationCards),
                    ),
                  )
                : Column(children: informationCards);
          },
        );
      },
      errorBuilder: (error, retry) => Center(child: Text(error.toString())),
    );
  }
}
