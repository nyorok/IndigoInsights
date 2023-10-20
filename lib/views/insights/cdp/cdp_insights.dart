import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/providers/indigo_asset_provider.dart';
import 'package:indigo_insights/utils/loader.dart';
import 'package:indigo_insights/views/insights/cdp/cdp_information.dart';

class CdpInsights extends HookConsumerWidget {
  const CdpInsights({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: SelectionArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Align(
            alignment: Alignment.topLeft,
            child: Wrap(
              children: [
                ...ref.watch(indigoAssetsProvider).when(
                      data: (indigoAssets) => indigoAssets
                          .map((e) => informationCard(
                              CdpInformation(
                                indigoAsset: e,
                              ),
                              context))
                          .toList(),
                      loading: () => [const Loader()],
                      error: (error, stackTrace) => [Text(error.toString())],
                    )
              ],
            ),
          ),
        ),
      ),
    );
  }

  ConstrainedBox informationCard(Widget widget, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double width = screenWidth - 480 > 480 ? 480 : screenWidth;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: width,
        maxHeight: 240,
      ),
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.all(8),
        child: Padding(padding: const EdgeInsets.all(16), child: widget),
      ),
    );
  }
}
