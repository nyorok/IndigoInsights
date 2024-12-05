import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/models/indigo_asset.dart';
import 'package:indigo_insights/providers/indigo_asset_provider.dart';

class ScrollableInformationCards extends ConsumerWidget {
  final Widget Function(IndigoAsset) cardContentBuilder;

  const ScrollableInformationCards(this.cardContentBuilder, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double maxCardWidth = screenWidth - 480 > 480 ? 480 : screenWidth;

    return ref.watch(indigoAssetsProvider).when(
          data: (indigoAssets) {
            final informationCards = indigoAssets.map((indigoAsset) {
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
              );
            }).toList();

            return LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                const appBarHeight = kToolbarHeight;
                final statusBarHeight = MediaQuery.of(context).padding.top;

                return isWide
                    ? SizedBox(
                        height: MediaQuery.of(context).size.height -
                            statusBarHeight -
                            appBarHeight -
                            8,
                        child: SingleChildScrollView(
                          child: Column(
                            children: informationCards.isNotEmpty
                                ? informationCards
                                : [const CircularProgressIndicator()],
                          ),
                        ),
                      )
                    : Column(
                        children: informationCards.isNotEmpty
                            ? informationCards
                            : [const CircularProgressIndicator()],
                      );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text(error.toString())),
        );
  }
}
