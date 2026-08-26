import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:indigo_insights/api/indigo_api/services/asset_price_service.dart';
import 'package:indigo_insights/api/indigo_api/services/asset_status_service.dart';
import 'package:indigo_insights/api/indigo_api/services/cdp_service.dart';
import 'package:indigo_insights/models/asset_price.dart';
import 'package:indigo_insights/models/asset_status.dart';
import 'package:indigo_insights/models/cdp.dart';
import 'package:indigo_insights/models/indigo_asset.dart';
import 'package:indigo_insights/repositories/asset_price_repository.dart';
import 'package:indigo_insights/repositories/asset_status_repository.dart';
import 'package:indigo_insights/repositories/cdp_repository.dart';
import 'package:indigo_insights/service_locator.dart';
import 'package:indigo_insights/theme/app_theme.dart';
import 'package:indigo_insights/theme/schemes/dark_scheme.dart';
import 'package:indigo_insights/utils/collateral_prices.dart';
import 'package:material_ui/material_ui.dart';
import 'package:indigo_insights/views/insights/redemption/redeemable_over_rmrs_chart.dart';
import 'package:indigo_insights/widgets/percentage_amount_chart.dart';

/// Fixtures are verbatim `/api/…` payloads captured on 2026-08-26. They pin the
/// V3 shape that broke this chart: `/api/asset-prices` publishes a single iUSD
/// row (USDCx) while 193 of the 316 open CDPs are iUSD, 184 of them on ADA.
List<T> _load<T>(String name, T Function(Map<String, dynamic>) fromJson) {
  final raw = jsonDecode(File('test/fixtures/$name').readAsStringSync());
  final list = raw is Map<String, dynamic> ? raw['data'] as List : raw as List;
  return list.map((e) => fromJson(e as Map<String, dynamic>)).toList();
}

void main() {
  final prices = _load('asset_prices.json', AssetPrice.fromJson);
  final cdps = _load('cdps.json', Cdp.fromJson);
  final statuses = AssetStatusService().parseAssetStatuses(
    jsonDecode(File('test/fixtures/assets_analytics.json').readAsStringSync())
        as Map<String, dynamic>,
  );

  test('the iUSD/ADA pair is absent from /api/asset-prices', () {
    final published = prices.where((p) => p.asset == 'iUSD').toList();
    expect(published, hasLength(1));
    expect(published.single.collateralAsset, isNot(''));
  });

  test('CollateralPrices derives the missing iUSD/ADA pair', () {
    final resolver = CollateralPrices.from(statuses, prices);
    final adaPerIusd = resolver.priceFor('iUSD', '');

    expect(adaPerIusd, isNotNull);
    // ~1 USD of iUSD at ~0.205 USD/ADA ≈ 4.87 ADA.
    expect(adaPerIusd, closeTo(4.87, 0.3));
  });

  test('iUSD CDPs on ADA collateral yield a redeemable series', () {
    final resolver = CollateralPrices.from(statuses, prices);
    final iusdOnAda = cdps
        .where((c) => c.asset == 'iUSD' && c.collateralAsset.isEmpty)
        .toList();
    expect(iusdOnAda, isNotEmpty);

    final price = resolver.priceFor('iUSD', '')!;
    final rmrs = List.generate(100, (i) => (150 + i * 5.0) / 100);
    final nonZero = <double>[
      for (final cdp in iusdOnAda)
        for (final rmr in rmrs)
          if (calculateRedeemableAmount(cdp, rmr, price).abs() > 0)
            calculateRedeemableAmount(cdp, rmr, price),
    ];

    expect(nonZero, isNotEmpty);
  });

  test('a CDP already above the RMR is not redeemable', () {
    final cdp = Cdp(
      asset: 'iUSD',
      collateralAmount: 1000,
      mintedAmount: 10,
      outputIndex: 0,
      outputHash: '',
      owner: '',
    );
    // 1000 ADA backing 10 iUSD at 5 ADA/iUSD is a 2000% ratio.
    expect(calculateRedeemableAmount(cdp, 1.5, 5), 0);
  });

  testWidgets('the iUSD chart renders a series instead of "No data available."', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1600, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    addTearDown(sl.reset);

    sl.registerLazySingleton(() => CdpRepository(_FixtureCdpService(cdps)));
    sl.registerLazySingleton(
      () => AssetPriceRepository(_FixtureAssetPriceService(prices)),
    );
    sl.registerLazySingleton(
      () => AssetStatusRepository(_FixtureAssetStatusService(statuses)),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(darkScheme, darkStyles),
        home: Scaffold(
          body: RedeemableOverRmrsChart(
            IndigoAsset(
              asset: 'iUSD',
              outputHash: '',
              outputIndex: 0,
              collateralAssets: const [],
              debtMintingFee: 0,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('No data available.'), findsNothing);
    expect(find.byType(PercentageAmountChart), findsOneWidget);
  });
}


class _FixtureCdpService extends CdpService {
  _FixtureCdpService(this._cdps);
  final List<Cdp> _cdps;
  @override
  Future<List<Cdp>> fetchCdps() async => _cdps;
}

class _FixtureAssetPriceService extends AssetPriceService {
  _FixtureAssetPriceService(this._prices);
  final List<AssetPrice> _prices;
  @override
  Future<List<AssetPrice>> fetchAssetPrices() async => _prices;
}

class _FixtureAssetStatusService extends AssetStatusService {
  _FixtureAssetStatusService(this._statuses);
  final List<AssetStatus> _statuses;
  @override
  Future<List<AssetStatus>> fetchAssetStatuses() async => _statuses;
}
